from collections import Optional
from math.bit import ctpop
from tensor import Tensor, TensorSpec

struct SparseArray[T: DType]:
    var mask: DTypePointer[DType.uint8]
    var values: DTypePointer[T]
    var mask_size: Int
    var values_count: Int
    var values_capacity: Int

    fn __init__(inout self, capacity: Int = 8):
        var _capacity = capacity if capacity >= 8 else 8
        self.mask_size = -(-_capacity >> 3)
        self.mask = DTypePointer[DType.uint8].alloc(self.mask_size)
        memset_zero(self.mask, self.mask_size)
        self.values_capacity = 4
        self.values_count = 0
        self.values = DTypePointer[T].alloc(self.values_capacity)

    fn __copyinit__(inout self, existing: Self):
        self.mask_size = existing.mask_size
        self.values_count = existing.values_count
        self.values_capacity = existing.values_capacity
        self.mask = DTypePointer[DType.uint8].alloc(self.mask_size)
        memcpy(self.mask, existing.mask, self.mask_size)
        self.values = DTypePointer[T].alloc(self.values_capacity)
        memcpy(self.values, existing.values, self.values_count)

    fn __moveinit__(inout self, owned existing: Self):
        self.mask_size = existing.mask_size
        self.values_count = existing.values_count
        self.values_capacity = existing.values_capacity
        self.mask = existing.mask
        self.values = existing.values

    fn __del__(owned self):
        self.mask.free()
        self.values.free()

    @always_inline
    fn __contains__(self, index: Int) -> Bool:
        var offset = index >> 3
        var bit_index = index & 7
        return self.contains(offset, bit_index)

    @always_inline
    fn contains(self, offset: Int, bit_index: Int) -> Bool:
        return offset < self.mask_size and self.mask.load(offset) & (1 << bit_index) != 0

    fn __setitem__(inout self, index: Int, value: SIMD[T, 1]):
        var offset = index >> 3
        var bit_index = index & 7
        
        if self.mask_size <= offset:
            var mask = DTypePointer[DType.uint8].alloc(offset + 1)
            memcpy(mask, self.mask, self.mask_size)
            memset_zero(mask.offset(self.mask_size), offset + 1 - self.mask_size)
            self.mask.free()
            self.mask = mask
            self.mask_size = offset + 1
        
        var p = self.mask.offset(offset)
        var mask = p.load()

        if self.contains(offset, bit_index):
            self.values.store(self._value_index(offset, bit_index), value)
            return

        p.store(mask | (1 << bit_index))

        if self.values_capacity <= self.values_count + 1:
            var values_capacity = self.values_capacity + (self.values_capacity >> 1)
            var values = DTypePointer[T].alloc(values_capacity)
            memcpy(values, self.values, self.values_count)
            self.values.free()
            self.values = values
            self.values_capacity = values_capacity

        var value_index = self._value_index(offset, bit_index)
        for i in range(self.values_count, value_index, -1):
            self.values.store(i, self.values.load(i-1))
        self.values.store(value_index, value)
        self.values_count += 1

    fn get(self, index: Int) -> Optional[SIMD[T, 1]]:
        var offset = index >> 3
        var bit_index = index & 7
        if not self.contains(offset, bit_index):
            return None
        return self.values.load(self._value_index(offset, bit_index))

    @always_inline
    fn _value_index(self, offset: Int, bit_index: Int) -> Int:
        
        if not self.contains(offset, bit_index):
            return -1
        
        alias width = 32
        var cursor = 0
        var result = 0
        while cursor + width < offset:
            var v = self.mask.simd_load[width](cursor)
            result += ctpop(v).cast[DType.int16]().reduce_add[1]().to_int()
            cursor += width
        
        while cursor <= offset:
            var v = self.mask.load(cursor)
            result += ctpop(v).to_int()
            cursor += 1

        result -= ctpop(self.mask.load(offset) >> (bit_index + 1)).to_int()
        return result - 1

    fn values_tensor(self) -> Tensor[T]:
        var spec = TensorSpec(DType.float32, self.values_count)
        var data = DTypePointer[T].alloc(self.values_count)
        memcpy(data, self.values, self.values_count)
        return Tensor(data, spec)

    fn debug(self):
        print_no_newline("(")
        print_no_newline(self.mask_size)
        print_no_newline(")")
        print_no_newline("[")
        for i in range(self.mask_size):
            print_no_newline(self.mask.load(i), "")
        print("]")

        print_no_newline("(")
        print_no_newline(self.values_count)
        print_no_newline(")")
        print_no_newline("[")
        for i in range(self.values_count):
            print_no_newline(self.values.load(i), "")
        print("]")
