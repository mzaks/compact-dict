from math.bit import bit_length, ctpop
from memory import memset_zero, memcpy
from .string_eq import eq
from .keys_container import KeysContainer
from .ahasher import ahash

struct Dict[
    V: CollectionElement, 
    hash: fn(String) -> UInt64 = ahash
]:
    var keys: KeysContainer
    var key_hashes: DynamicVector[UInt64]
    var values: DynamicVector[V]
    var key_map: DTypePointer[DType.uint32]
    var deleted_mask: DTypePointer[DType.uint8]
    var count: Int
    var capacity: Int

    fn __init__(inout self, capacity: Int = 16):
        self.count = 0
        if capacity <= 8:
            self.capacity = 8
        else:
            var icapacity = Int64(capacity)
            self.capacity = capacity if ctpop(icapacity) == 1 else
                            1 << (bit_length(icapacity)).to_int()
        self.keys = KeysContainer(capacity)
        self.key_hashes = DynamicVector[UInt64](self.capacity)
        self.values = DynamicVector[V](self.capacity)
        self.key_map = DTypePointer[DType.uint32].alloc(self.capacity)
        self.deleted_mask = DTypePointer[DType.uint8].alloc(self.capacity >> 3)
        memset_zero(self.key_map, self.capacity)
        memset_zero(self.deleted_mask, self.capacity >> 3)

    fn __copyinit__(inout self, existing: Self):
        self.count = existing.count
        self.capacity = existing.capacity
        self.keys = existing.keys
        self.key_hashes = existing.key_hashes
        self.values = existing.values
        self.key_map = DTypePointer[DType.uint32].alloc(self.capacity)
        memcpy(self.key_map, existing.key_map, self.capacity)
        self.deleted_mask = DTypePointer[DType.uint8].alloc(self.capacity >> 3)
        memcpy(self.deleted_mask, existing.deleted_mask, self.capacity >> 3)

    fn __moveinit__(inout self, owned existing: Self):
        self.count = existing.count
        self.capacity = existing.capacity
        self.keys = existing.keys^
        self.key_hashes = existing.key_hashes^
        self.values = existing.values^
        self.key_map = existing.key_map
        self.deleted_mask = existing.deleted_mask

    fn __del__(owned self):
        self.key_map.free()
        self.deleted_mask.free()

    fn put(inout self, key: String, value: V):
        if self.count / self.capacity >= 0.87:
            self._rehash()
        
        let key_hash = hash(key)
        let key_hash_vec = SIMD[DType.uint64, 8](key_hash)
        let modulo_mask = self.capacity - 1
        var key_map_index = (key_hash & modulo_mask).to_int()
        while True:
            let key_index = self.key_map.offset(key_map_index).load().to_int()
            if key_index == 0:
                self.keys.add(key)
                self.key_hashes.push_back(key_hash)
                self.values.push_back(value)
                self.count += 1
                self.key_map.offset(key_map_index).store(UInt32(self.keys.count))
                return

            let other_key_hash = self.key_hashes[key_index - 1]
            let other_key = self.keys[key_index - 1]
            if other_key_hash == key_hash and eq(other_key, key):
                self.values[key_index - 1] = value # replace value
                if self._is_deleted(key_index - 1):
                    self.count += 1
                    self._not_deleted(key_index - 1)
                return
            
            key_map_index = (key_map_index + 1) & modulo_mask

    @always_inline
    fn _is_deleted(self, index: Int) -> Bool:
        let offset = index // 8
        let bit_index = index & 7
        return self.deleted_mask.offset(offset).load() & (1 << bit_index) != 0

    @always_inline
    fn _deleted(self, index: Int):
        let offset = index // 8
        let bit_index = index & 7
        let p = self.deleted_mask.offset(offset)
        let mask = p.load()
        p.store(mask | (1 << bit_index))
    
    @always_inline
    fn _not_deleted(self, index: Int):
        let offset = index // 8
        let bit_index = index & 7
        let p = self.deleted_mask.offset(offset)
        let mask = p.load()
        p.store(mask & ~(1 << bit_index))

    @always_inline
    fn _rehash(inout self):
        let old_mask_capacity = self.capacity >> 3
        self.key_map.free()
        self.capacity <<= 1
        let mask_capacity = self.capacity >> 3
        self.key_map = DTypePointer[DType.uint32].alloc(self.capacity)
        memset_zero(self.key_map, self.capacity)
        
        let _deleted_mask = DTypePointer[DType.uint8].alloc(mask_capacity)
        memset_zero(_deleted_mask, mask_capacity)
        memcpy(_deleted_mask, self.deleted_mask, old_mask_capacity)
        self.deleted_mask.free()
        self.deleted_mask = _deleted_mask

        let modulo_mask = self.capacity - 1
        for i in range(len(self.keys)):
            let key = self.keys[i]
            let key_hash = self.key_hashes[i]
            let key_hash_vec = SIMD[DType.uint64, 4](key_hash)

            var key_map_index = (key_hash & modulo_mask).to_int()

            var searching = True
            while searching:
                let key_index = self.key_map.offset(key_map_index).load().to_int()

                if key_index == 0:
                    self.key_map.offset(key_map_index).store(UInt32(i) + 1)
                    searching = False
                
                key_map_index = (key_map_index + 1) & modulo_mask    

    fn get(self, key: String, default: V) -> V:
        let key_hash = hash(key)
        let modulo_mask = self.capacity - 1
        let key_hash_vec = SIMD[DType.uint64, 4](key_hash)

        var key_map_index = (key_hash & modulo_mask).to_int()
        while True:
            let key_index = self.key_map.offset(key_map_index).load().to_int()
            
            if key_index == 0:
                return default
            let other_key = self.keys[key_index - 1]
            let other_key_hash = self.key_hashes[key_index - 1]
            if key_hash == other_key_hash and eq(other_key, key):
                if self._is_deleted(key_index - 1):
                    return default
                return self.values[key_index - 1]
            key_map_index = (key_map_index + 1) & modulo_mask

    fn delete(inout self, key: String):
        let key_hash = hash(key)
        let modulo_mask = self.capacity - 1
        let key_hash_vec = SIMD[DType.uint64, 4](key_hash)

        var key_map_index = (key_hash & modulo_mask).to_int()
        while True:
            let key_index = self.key_map.offset(key_map_index).load().to_int()

            if key_index == 0:
                return
            let other_key = self.keys[key_index - 1]
            let other_key_hash = self.key_hashes[key_index - 1]
            if key_hash == other_key_hash and eq(other_key, key):
                self.count -= 1
                return self._deleted(key_index - 1)
            
            key_map_index = (key_map_index + 1) & modulo_mask    
