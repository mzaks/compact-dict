from bit import pop_count, bit_width
from memory import memset_zero, memcpy
from .key_eq import eq
from .keys_container import KeysContainer, KeyRef, Keyable
from .ahasher import ahash
from .single_key_builder import SingleKeyBuilder
 
struct Dict[
    V: Copyable & Movable,
    hash: fn(KeyRef) -> UInt64 = ahash,
    KeyCountType: DType = DType.uint32,
    KeyOffsetType: DType = DType.uint32,
    destructive: Bool = True,
    caching_hashes: Bool = True,
](Sized):
    var keys: KeysContainer[KeyOffsetType]
    var key_hashes: UnsafePointer[Scalar[KeyCountType]]
    var values: List[V]
    var slot_to_index: UnsafePointer[Scalar[KeyCountType]]
    var deleted_mask: UnsafePointer[UInt8]
    var count: Int
    var capacity: Int
    var key_builder: SingleKeyBuilder

    fn __init__(out self, capacity: Int = 16):
        constrained[
            KeyCountType == DType.uint8 or 
            KeyCountType == DType.uint16 or 
            KeyCountType == DType.uint32 or 
            KeyCountType == DType.uint64,
            "KeyCountType needs to be an unsigned integer"
        ]()
        self.count = 0
        if capacity <= 8:
            self.capacity = 8
        else:
            var icapacity = Int64(capacity)
            self.capacity = capacity if pop_count(icapacity) == 1 else
                            1 << Int(bit_width(icapacity))
        self.keys = KeysContainer[KeyOffsetType](capacity)
        self.key_builder = SingleKeyBuilder()
        @parameter
        if caching_hashes:
            self.key_hashes = UnsafePointer[Scalar[KeyCountType]].alloc(self.capacity)
        else:
            self.key_hashes = UnsafePointer[Scalar[KeyCountType]].alloc(0)
        self.values = List[V](capacity=capacity)
        self.slot_to_index = UnsafePointer[Scalar[KeyCountType]].alloc(self.capacity)
        memset_zero(self.slot_to_index, self.capacity)
        @parameter
        if destructive:
            self.deleted_mask = UnsafePointer[UInt8].alloc(self.capacity >> 3)
            memset_zero(self.deleted_mask, self.capacity >> 3)
        else:
            self.deleted_mask = UnsafePointer[UInt8].alloc(0)

    fn __copyinit__(out self, existing: Self):
        self.count = existing.count
        self.capacity = existing.capacity
        self.keys = existing.keys
        self.key_builder = existing.key_builder
        @parameter
        if caching_hashes:
            self.key_hashes = UnsafePointer[Scalar[KeyCountType]].alloc(self.capacity)
            memcpy(self.key_hashes, existing.key_hashes, self.capacity)
        else:
            self.key_hashes = UnsafePointer[Scalar[KeyCountType]].alloc(0)
        self.values = existing.values
        self.slot_to_index = UnsafePointer[Scalar[KeyCountType]].alloc(self.capacity)
        memcpy(self.slot_to_index, existing.slot_to_index, self.capacity)
        @parameter
        if destructive:
            self.deleted_mask = UnsafePointer[UInt8].alloc(self.capacity >> 3)
            memcpy(self.deleted_mask, existing.deleted_mask, self.capacity >> 3)
        else:
            self.deleted_mask = UnsafePointer[UInt8].alloc(0)

    fn __moveinit__(out self, owned existing: Self):
        self.count = existing.count
        self.capacity = existing.capacity
        self.keys = existing.keys^
        self.key_builder = existing.key_builder^
        self.key_hashes = existing.key_hashes
        self.values = existing.values^
        self.slot_to_index = existing.slot_to_index
        self.deleted_mask = existing.deleted_mask

    fn __del__(owned self):
        self.slot_to_index.free()
        self.deleted_mask.free()
        self.key_hashes.free()

    fn __len__(self) -> Int:
        return self.count

    @always_inline
    fn __contains__[T: Keyable](self, key: T) -> Bool:
        try:
            self.key_builder.reset()
            key.accept(self.key_builder)
            var key_ref = self.key_builder.get_key()
            return self._find_key_index(key_ref) != 0
        except:
            return False

    fn put[T: Keyable](mut self, key: T, value: V) raises -> Bool:
        """Return True when value is inserted and not updated."""
        if self.count / self.capacity >= 0.87:
            self._rehash()
        key.accept(self.keys)
        self.keys.end_key()
        var key_ref = self.keys.get_last()

        var key_hash = hash(key_ref).cast[KeyCountType]()
        var modulo_mask = self.capacity - 1
        var slot = Int(key_hash & modulo_mask)
        while True:
            var key_index = Int(self.slot_to_index.load(slot))
            if key_index == 0:
                @parameter
                if caching_hashes:
                    self.key_hashes.store(slot, key_hash)
                self.values.append(value)
                self.count += 1
                self.slot_to_index.store(slot, SIMD[KeyCountType, 1](self.keys.count))
                return True
            @parameter
            if caching_hashes:
                var other_key_hash = self.key_hashes[slot]
                if other_key_hash == key_hash:
                    var other_key = self.keys[key_index - 1]
                    if eq(other_key, key_ref):
                        self.values[key_index - 1] = value # replace value
                        self.keys.drop_last()
                        @parameter
                        if destructive:
                            if self._is_deleted(key_index - 1):
                                self.count += 1
                                self._not_deleted(key_index - 1)
                                return True
                        return False
            else:
                var other_key = self.keys[key_index - 1]
                if eq(other_key, key_ref):
                    self.values[key_index - 1] = value # replace value
                    self.keys.drop_last()
                    @parameter
                    if destructive:
                        if self._is_deleted(key_index - 1):
                            self.count += 1
                            self._not_deleted(key_index - 1)
                            return True
                    return False
            
            slot = (slot + 1) & modulo_mask

    @always_inline
    fn _is_deleted(self, index: Int) -> Bool:
        var offset = index >> 3
        var bit_index = index & 7
        return self.deleted_mask.offset(offset).load() & (1 << bit_index) != 0

    @always_inline
    fn _deleted(self, index: Int):
        var offset = index >> 3
        var bit_index = index & 7
        var p = self.deleted_mask.offset(offset)
        var mask = p.load()
        p.store(mask | (1 << bit_index))
    
    @always_inline
    fn _not_deleted(self, index: Int):
        var offset = index >> 3
        var bit_index = index & 7
        var p = self.deleted_mask.offset(offset)
        var mask = p.load()
        p.store(mask & ~(1 << bit_index))

    @always_inline
    fn _rehash(mut self) raises:
        var old_slot_to_index = self.slot_to_index
        var old_capacity = self.capacity
        self.capacity <<= 1
        var mask_capacity = self.capacity >> 3
        self.slot_to_index = UnsafePointer[Scalar[KeyCountType]].alloc(self.capacity)
        memset_zero(self.slot_to_index, self.capacity)
        
        var key_hashes = self.key_hashes
        @parameter
        if caching_hashes:
            key_hashes = UnsafePointer[Scalar[KeyCountType]].alloc(self.capacity)
            
        @parameter
        if destructive:
            var deleted_mask = UnsafePointer[UInt8].alloc(mask_capacity)
            memset_zero(deleted_mask, mask_capacity)
            memcpy(deleted_mask, self.deleted_mask, old_capacity >> 3)
            self.deleted_mask.free()
            self.deleted_mask = deleted_mask

        var modulo_mask = self.capacity - 1
        for i in range(old_capacity):
            if old_slot_to_index[i] == 0:
                continue
            var key_hash = SIMD[KeyCountType, 1](0)
            @parameter
            if caching_hashes:
                key_hash = self.key_hashes[i]
            else:
                key_hash = hash(self.keys[Int(old_slot_to_index[i] - 1)]).cast[KeyCountType]()

            var slot = Int(key_hash & modulo_mask)

            while True:
                var key_index = Int(self.slot_to_index.load(slot))
                if key_index == 0:
                    self.slot_to_index.store(slot, old_slot_to_index[i])
                    break
                else:
                    slot = (slot + 1) & modulo_mask
            @parameter
            if caching_hashes:
                key_hashes[slot] = key_hash  
        
        @parameter
        if caching_hashes:
            self.key_hashes.free()
            self.key_hashes = key_hashes
        old_slot_to_index.free()

    @always_inline
    fn get[T: Keyable](mut self, key: T, default: V) raises -> V:
        self.key_builder.reset()
        key.accept(self.key_builder)
        var key_ref = self.key_builder.get_key()
        var key_index = self._find_key_index(key_ref)
        if key_index == 0:
            return default
        @parameter
        if destructive: 
            if self._is_deleted(key_index - 1):
                return default
        return self.values[key_index - 1]        

    fn delete[T: Keyable](mut self, key: T) raises:
        @parameter
        if not destructive:
            return

        self.key_builder.reset()
        key.accept(self.key_builder)
        var key_ref = self.key_builder.get_key()
        var key_index = self._find_key_index(key_ref)
        if key_index == 0:
            return
        if not self._is_deleted(key_index - 1):
            self.count -= 1
        self._deleted(key_index - 1)

    fn clear(mut self):
        self.values.clear()
        self.keys.clear()
        memset_zero(self.slot_to_index, self.capacity)
        @parameter
        if destructive:
            memset_zero(self.deleted_mask, self.capacity >> 3)
        self.count = 0

    fn _find_key_index(self, key_ref: KeyRef) raises -> Int:
        var key_hash = hash(key_ref).cast[KeyCountType]()
        var modulo_mask = self.capacity - 1
        var slot = Int(key_hash & modulo_mask)
        while True:
            var key_index = Int(self.slot_to_index.load(slot))
            if key_index == 0:
                return key_index
            @parameter
            if caching_hashes:
                var other_key_hash = self.key_hashes[slot]
                if key_hash == other_key_hash:
                    var other_key = self.keys[key_index - 1]
                    if eq(other_key, key_ref):
                        return key_index
            else:
                var other_key = self.keys[key_index - 1]
                if eq(other_key, key_ref):
                    return key_index
            slot = (slot + 1) & modulo_mask


    fn debug(self) raises:
        print("Dict count:", self.count, "and capacity:", self.capacity)
        print("KeyMap:")
        for i in range(self.capacity):
            var end = ", " if i < self.capacity - 1 else "\n"
            print(self.slot_to_index.load(i), end=end)
        print("Keys:")
        self.keys.print_keys()
        @parameter
        if caching_hashes:
            print("KeyHashes:")
            for i in range(self.capacity):
                var end = ", " if i < self.capacity - 1 else "\n"
                if self.slot_to_index.load(i) > 0:
                    print(self.key_hashes.load(i), end=end)
                else:
                    print(0, end=end)
