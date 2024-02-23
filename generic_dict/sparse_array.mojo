from math.bit import ctpop
from tensor import Tensor, TensorSpec

struct SparseArray[T: DType]:
    var mask: DTypePointer[DType.uint8]
    var values: DTypePointer[T]
    var mask_size: Int
    var values_count: Int
    var values_capacity: Int

    fn __init__(inout self, capacity: Int):
        self.mask_size = -(-capacity >> 3)
        self.mask = DTypePointer[DType.uint8].alloc(self.mask_size)
        memset_zero(self.mask, self.mask_size)
        self.values_capacity = 4
        self.values_count = 0
        self.values = DTypePointer[T].alloc(self.values_capacity)

    fn __del__(owned self):
        self.mask.free()
        self.values.free()

    @always_inline
    fn __contains__(self, index: Int) -> Bool:
        let offset = index >> 3
        let bit_index = index & 7
        return self.mask.load(offset) & (1 << bit_index) != 0

    @always_inline
    fn __contains__(self, offset: Int, bit_index: Int) -> Bool:
        return self.mask.load(offset) & (1 << bit_index) != 0

    fn __setitem__(inout self, index: Int, value: SIMD[T, 1]):
        let offset = index >> 3
        let bit_index = index & 7
        
        if self.mask_size <= offset:
            var mask = DTypePointer[DType.uint8].alloc(offset + 1)
            memcpy(mask, self.mask, self.mask_size)
            memset_zero(mask.offset(self.mask_size), offset + 1 - self.mask_size)
            self.mask.free()
            self.mask = mask
            self.mask_size = offset + 1
        
        let p = self.mask.offset(offset)
        let mask = p.load()

        if self.__contains__(offset, bit_index):
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

        let value_index = self._value_index(offset, bit_index)
        for i in range(self.values_count, value_index, -1):
            self.values.store(i, self.values.load(i-1))
        self.values.store(value_index, value)
        self.values_count += 1

    fn _value_index(self, offset: Int, bit_index: Int) -> Int:
        
        if not self.__contains__(offset, bit_index):
            return -1
        
        alias width = 32
        var cursor = 0
        var result = 0
        while cursor + width < offset:
            let v = self.mask.simd_load[width](cursor)
            result += ctpop(v).cast[DType.int16]().reduce_add[1]().to_int()
            cursor += width
        
        while cursor <= offset:
            let v = self.mask.load(cursor)
            result += ctpop(v).to_int()
            cursor += 1

        result -= ctpop(self.mask.load(offset) >> (bit_index + 1)).to_int()
        return result - 1

    fn values_tensor(self) -> Tensor[T]:
        let spec = TensorSpec(DType.float32, self.values_count)
        let data = DTypePointer[T].alloc(self.values_count)
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
