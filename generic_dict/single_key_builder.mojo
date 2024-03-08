from math import bitcast
from .keys_container import KeysBuilder, KeyRef

struct SingleKeyBuilder(KeysBuilder):
    var key: DTypePointer[DType.uint8]
    var allocated_bytes: Int
    var key_size: Int

    fn __init__(inout self, bytes: Int = 64):
        self.allocated_bytes = bytes
        self.key = DTypePointer[DType.uint8].alloc(self.allocated_bytes)
        self.key_size = 0

    fn __copyinit__(inout self, existing: Self):
        self.allocated_bytes = existing.allocated_bytes
        self.key = DTypePointer[DType.uint8].alloc(self.allocated_bytes)
        memcpy(self.key, existing.key, self.allocated_bytes)
        self.key_size = existing.key_size

    fn __moveinit__(inout self, owned existing: Self):
        self.allocated_bytes = existing.allocated_bytes
        self.key = existing.key
        self.key_size = existing.key_size

    fn __del__(owned self):
        self.key.free()

    @always_inline  
    fn add[T: DType, size: Int](inout self, value: SIMD[T, size]):
        var prev_end = 0
        var key_length = size * T.sizeof()
        var old_key_size = self.key_size
        self.key_size += key_length
        
        var needs_realocation = False
        while self.key_size > self.allocated_bytes:
            self.allocated_bytes += self.allocated_bytes >> 1
            needs_realocation = True

        if needs_realocation:
            var key = DTypePointer[DType.uint8].alloc(self.allocated_bytes)
            memcpy(key, self.key, old_key_size)
            self.key.free()
            self.key = key
        
        self.key.simd_store(old_key_size, bitcast[DType.uint8, size * T.sizeof()](value))
    
    @always_inline
    fn add_buffer[T: DType](inout self, pointer: DTypePointer[T], size: Int):
        var key_length = size * T.sizeof()
        var old_key_size = self.key_size
        self.key_size += key_length
        
        var needs_realocation = False
        while self.key_size > self.allocated_bytes:
            self.allocated_bytes += self.allocated_bytes >> 1
            needs_realocation = True

        if needs_realocation:
            var key = DTypePointer[DType.uint8].alloc(self.allocated_bytes)
            memcpy(key, self.key, old_key_size)
            self.key.free()
            self.key = key
        
        memcpy(self.key.offset(old_key_size), pointer.bitcast[DType.uint8](), key_length)

    @always_inline
    fn get_key(self) -> KeyRef:
        return KeyRef(self.key, self.key_size)

    @always_inline
    fn reset(inout self):
        self.key_size = 0