from collections.vector import InlinedFixedVector
from math import bitcast

trait Keyable:
    fn accept[T: KeysBuilder](self, inout keys_builder: T): ...

alias lookup = String("0123456789abcdef")

@value
struct KeyRef(Stringable):
    var pointer: DTypePointer[DType.uint8]
    var size: Int

    fn __str__(self) -> String:
        var result = String("(") + String(self.size) + (")")
        for i in range(self.size):
            result += lookup[(self.pointer.load(i) >> 4).to_int()]
            result += lookup[(self.pointer.load(i) & 0xf).to_int()]
        return result

trait KeysBuilder:
    fn add[T: DType, size: Int](inout self, value: SIMD[T, size]): ...
    fn add_buffer[T: DType](inout self, pointer: DTypePointer[T], size: Int): ...

struct KeysContainer[KeyEndType: DType = DType.uint32](Sized, KeysBuilder):
    var keys: DTypePointer[DType.uint8]
    var allocated_bytes: Int
    var keys_end: DTypePointer[KeyEndType]
    var count: Int
    var capacity: Int
    var key_size: Int

    fn __init__(inout self, capacity: Int):
        constrained[
            KeyEndType == DType.uint8 or 
            KeyEndType == DType.uint16 or 
            KeyEndType == DType.uint32 or 
            KeyEndType == DType.uint64,
            "KeyEndType needs to be an unsigned integer"
        ]()
        self.allocated_bytes = capacity << 3
        self.keys = DTypePointer[DType.uint8].alloc(self.allocated_bytes)
        self.keys_end = DTypePointer[KeyEndType].alloc(capacity)
        self.count = 0
        self.capacity = capacity
        self.key_size = 0

    fn __copyinit__(inout self, existing: Self):
        self.allocated_bytes = existing.allocated_bytes
        self.count = existing.count
        self.capacity = existing.capacity
        self.key_size = existing.key_size
        self.keys = DTypePointer[DType.uint8].alloc(self.allocated_bytes)
        memcpy(self.keys, existing.keys, self.allocated_bytes)
        self.keys_end = DTypePointer[KeyEndType].alloc(self.allocated_bytes)
        memcpy(self.keys_end, existing.keys_end, self.capacity)

    fn __moveinit__(inout self, owned existing: Self):
        self.allocated_bytes = existing.allocated_bytes
        self.count = existing.count
        self.capacity = existing.capacity
        self.key_size = existing.key_size
        self.keys = existing.keys
        self.keys_end = existing.keys_end

    fn __del__(owned self):
        self.keys.free()
        self.keys_end.free()

    @always_inline  
    fn add[T: DType, size: Int](inout self, value: SIMD[T, size]):
        var prev_end = 0 if self.count == 0 else self.keys_end[self.count - 1]
        var key_length = size * T.sizeof()
        var old_key_size = self.key_size
        self.key_size += key_length
        var new_end = prev_end + self.key_size
        
        var needs_realocation = False
        while new_end > self.allocated_bytes:
            self.allocated_bytes += self.allocated_bytes >> 1
            needs_realocation = True

        if needs_realocation:
            var keys = DTypePointer[DType.uint8].alloc(self.allocated_bytes)
            memcpy(keys, self.keys, prev_end.to_int() + old_key_size)
            self.keys.free()
            self.keys = keys
        
        self.keys.simd_store(prev_end.to_int() + old_key_size, bitcast[DType.uint8, size * T.sizeof()](value))

    @always_inline
    fn add_buffer[T: DType](inout self, pointer: DTypePointer[T], size: Int):
        var prev_end = 0 if self.count == 0 else self.keys_end[self.count - 1]
        var key_length = size * T.sizeof()
        var old_key_size = self.key_size
        self.key_size += key_length
        var new_end = prev_end + self.key_size
        
        var needs_realocation = False
        while new_end > self.allocated_bytes:
            self.allocated_bytes += self.allocated_bytes >> 1
            needs_realocation = True

        if needs_realocation:
            var keys = DTypePointer[DType.uint8].alloc(self.allocated_bytes)
            memcpy(keys, self.keys, prev_end.to_int() + old_key_size)
            self.keys.free()
            self.keys = keys
        
        memcpy(self.keys.offset(prev_end + old_key_size), pointer.bitcast[DType.uint8](), key_length)

    @always_inline
    fn end_key(inout self):
        var prev_end = 0 if self.count == 0 else self.keys_end[self.count - 1]
        var count = self.count + 1
        if count >= self.capacity:
            var new_capacity = self.capacity + (self.capacity >> 1)
            var keys_end = DTypePointer[KeyEndType].alloc(self.allocated_bytes)
            memcpy(keys_end, self.keys_end, self.capacity)
            self.keys_end.free()
            self.keys_end = keys_end
            self.capacity = new_capacity

        self.keys_end.store(self.count, prev_end + self.key_size)
        self.count = count
        self.key_size = 0

    @always_inline
    fn drop_last(inout self):
        self.count -= 1

    @always_inline
    fn get_last(self) raises -> KeyRef:
        return self.get(self.count - 1)

    @always_inline
    fn get(self, index: Int) raises -> KeyRef:
        if index < 0 or index >= self.count:
            raise "Invalid index"
        var start = 0 if index == 0 else self.keys_end[index - 1].to_int()
        var length = self.keys_end[index].to_int() - start
        return KeyRef(self.keys.offset(start), length)

    @always_inline
    fn __getitem__(self, index: Int) raises -> KeyRef:
        return self.get(index)

    @always_inline
    fn __len__(self) -> Int:
        return self.count

    fn print_keys(self) raises:
        print_no_newline("(")
        print_no_newline(self.count)
        print_no_newline(")[")
        for i in range(self.count):
            print_no_newline(self[i])
            if i < self.count - 1:
                print_no_newline(", ")
        print("]")
