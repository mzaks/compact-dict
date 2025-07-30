from collections import Optional
from bit import pop_count
from tensor import Tensor, TensorSpec
from memory import memset_zero, memcpy

struct SparseArray[T: DType]:
    var mask: UnsafePointer[UInt8]
    var values: UnsafePointer[Scalar[T]]
    var mask_size: Int
    var values_count: Int
    var values_capacity: Int

    fn __init__(out self, capacity: Int = 8):
        var _capacity = capacity if capacity >= 8 else 8
        self.mask_size = -(-_capacity >> 3)
        self.mask = UnsafePointer[UInt8].alloc(self.mask_size)
        memset_zero(self.mask, self.mask_size)
        self.values_capacity = 4
        self.values_count = 0
        self.values = UnsafePointer[Scalar[T]].alloc(self.values_capacity)

    fn __copyinit__(out self, existing: Self):
        self.mask_size = existing.mask_size
        self.values_count = existing.values_count
        self.values_capacity = existing.values_capacity
        self.mask = UnsafePointer[UInt8].alloc(self.mask_size)
        memcpy(self.mask, existing.mask, self.mask_size)
        self.values = UnsafePointer[Scalar[T]].alloc(self.values_capacity)
        memcpy(self.values, existing.values, self.values_count)

    fn __moveinit__(out self, owned existing: Self):
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

    fn __setitem__(mut self, index: Int, value: SIMD[T, 1]):
        var offset = index >> 3
        var bit_index = index & 7
        
        if self.mask_size <= offset:
            var mask = UnsafePointer[UInt8].alloc(offset + 1)
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
            var values = UnsafePointer[Scalar[T]].alloc(values_capacity)
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

        var idx = self._value_index(offset, bit_index)
        if idx < 0 or idx >= self.values_count:
            print("ERROR: Invalid value index:", idx)
            return None
        return self.values.load(idx)

    @always_inline
    fn _value_index(self, offset: Int, bit_index: Int) -> Int:
        var count = 0
        var i = 0
        while i < offset:
            count += Int(pop_count(self.mask.load(i)))
            i += 1

        var byte = self.mask.load(offset)
        var mask = (1 << bit_index) - 1
        var before_bit = byte & mask
        count += Int(pop_count(before_bit))

        return count

    fn dense_values_list(self) -> List[Scalar[T]]:
        var count = self.values_count
        if count > 10000:
            print("WARNING: very large count", count)
            count = 10000  # prevent hang

        if count == 0:
            return []

        var result = List[Scalar[T]](unsafe_uninit_length=count)
        for i in range(count):
            result[i] = self.values.load(i)
        return result


    fn debug(self):
        print("(" + String(self.mask_size) + ")[")
        for i in range(self.mask_size):
            var end = ", " if i < self.mask_size - 1 else ""
            print(self.mask.load(i), end=end)
        print("]")

        print("(" + String(self.values_count) + ")[")
        for i in range(self.values_count):
            var end = ", " if i < self.mask_size - 1 else ""
            print(self.values.load(i), end=end)
        print("]")
