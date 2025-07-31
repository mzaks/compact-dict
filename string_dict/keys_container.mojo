from collections.vector import InlinedFixedVector
from memory import memcpy

struct KeysContainer[KeyEndType: DType = DType.uint32](Sized):
    var keys: UnsafePointer[UInt8]
    var allocated_bytes: Int
    var keys_end: UnsafePointer[Scalar[KeyEndType]]
    var count: Int
    var capacity: Int

    fn __init__(out self, capacity: Int):
        constrained[
            KeyEndType == DType.uint8 or 
            KeyEndType == DType.uint16 or 
            KeyEndType == DType.uint32 or 
            KeyEndType == DType.uint64,
            "KeyEndType needs to be an unsigned integer"
        ]()
        self.allocated_bytes = capacity << 3
        self.keys = UnsafePointer[UInt8].alloc(self.allocated_bytes)
        self.keys_end = UnsafePointer[Scalar[KeyEndType]].alloc(capacity)
        self.count = 0
        self.capacity = capacity

    fn __copyinit__(out self, existing: Self):
        self.allocated_bytes = existing.allocated_bytes
        self.count = existing.count
        self.capacity = existing.capacity
        self.keys = UnsafePointer[UInt8].alloc(self.allocated_bytes)
        memcpy(self.keys, existing.keys, self.allocated_bytes)
        self.keys_end = UnsafePointer[Scalar[KeyEndType]].alloc(self.allocated_bytes)
        memcpy(self.keys_end, existing.keys_end, self.capacity)

    fn __moveinit__(out self, owned existing: Self):
        self.allocated_bytes = existing.allocated_bytes
        self.count = existing.count
        self.capacity = existing.capacity
        self.keys = existing.keys
        self.keys_end = existing.keys_end

    fn __del__(owned self):
        self.keys.free()
        self.keys_end.free()

    @always_inline
    fn add(mut self, key: String):
        var prev_end = 0 if self.count == 0 else self.keys_end[self.count - 1]
        var key_length = len(key)
        var new_end = prev_end + key_length
        
        var needs_realocation = False
        while new_end > self.allocated_bytes:
            self.allocated_bytes += self.allocated_bytes >> 1
            needs_realocation = True

        if needs_realocation:
            var keys = UnsafePointer[UInt8].alloc(self.allocated_bytes)
            memcpy(keys, self.keys, Int(prev_end))
            self.keys.free()
            self.keys = keys
        
        memcpy(self.keys.offset(prev_end), UnsafePointer(key.unsafe_ptr()), key_length)
        var count = self.count + 1
        if count >= self.capacity:
            var new_capacity = self.capacity + (self.capacity >> 1)
            var keys_end = UnsafePointer[Scalar[KeyEndType]].alloc(self.allocated_bytes)
            memcpy(keys_end, self.keys_end, self.capacity)
            self.keys_end.free()
            self.keys_end = keys_end
            self.capacity = new_capacity

        self.keys_end.store(self.count, new_end)
        self.count = count


    @always_inline
    fn get(self, index: Int) -> StringSlice[StaticConstantOrigin]:
        if index < 0 or index >= self.count:
            return ""
        var start = 0 if index == 0 else Int(self.keys_end[index - 1])
        var length = Int(self.keys_end[index]) - start
        return StringSlice[StaticConstantOrigin](ptr=self.keys.offset(start), length=length)

    @always_inline
    fn clear(mut self):
        self.count = 0

    @always_inline
    fn __getitem__(self, index: Int) -> StringSlice[StaticConstantOrigin]:
        return self.get(index)

    @always_inline
    fn __len__(self) -> Int:
        return self.count

    fn keys_vec(self) -> InlinedFixedVector[StringSlice[StaticConstantOrigin]]:
        var keys = InlinedFixedVector[StringSlice[StaticConstantOrigin]](self.count)
        for i in range(self.count):
            keys.append(self[i])
        return keys

    fn print_keys(self):
        print("(" + str(self.count) + ")[", end="")
        for i in range(self.count):
            var end = ", " if i < self.capacity - 1 else ""
            print(self[i], end=end)
        print("]")
