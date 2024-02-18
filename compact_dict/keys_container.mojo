struct KeysContainer(Sized):
    var keys: DTypePointer[DType.int8]
    var allocated_bytes: Int
    var keys_end: DynamicVector[Int]
    var count: Int

    fn __init__(inout self, capacity: Int):
        self.allocated_bytes = capacity << 3
        self.keys = DTypePointer[DType.int8].alloc(self.allocated_bytes)
        self.keys_end = DynamicVector[Int]()
        self.count = 0

    fn __copyinit__(inout self, existing: Self):
        self.allocated_bytes = existing.allocated_bytes
        self.keys = DTypePointer[DType.int8].alloc(self.allocated_bytes)
        memcpy(self.keys, existing.keys, self.allocated_bytes)
        self.keys_end = existing.keys_end
        self.count = existing.count

    fn __moveinit__(inout self, owned existing: Self):
        self.allocated_bytes = existing.allocated_bytes
        self.keys = existing.keys
        self.keys_end = existing.keys_end^
        self.count = existing.count

    fn __del__(owned self):
        self.keys.free()

    @always_inline
    fn add(inout self, key: String):
        let prev_end = 0 if self.count == 0 else self.keys_end[self.count - 1]
        let key_length = len(key)
        let new_end = prev_end + key_length
        
        var needs_realocation = False
        while new_end > self.allocated_bytes:
            self.allocated_bytes <<= 1
            needs_realocation = True

        if needs_realocation:
            var keys = DTypePointer[DType.int8].alloc(self.allocated_bytes)
            memcpy(keys, self.keys, prev_end)
            self.keys.free()
            self.keys = keys
        
        memcpy(self.keys.offset(prev_end), key._as_ptr(), key_length)
        self.keys_end.append(new_end)
        self.count += 1

    @always_inline
    fn get(self, index: Int) -> StringRef:
        if index < 0 or index >= self.count:
            return ""
        let start = 0 if index == 0 else self.keys_end[index - 1]
        let length = self.keys_end[index] - start
        return StringRef(self.keys.offset(start), length)

    fn __getitem__(self, index: Int) -> StringRef:
        return self.get(index)

    fn __len__(self) -> Int:
        return self.count