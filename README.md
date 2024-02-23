`compact-dict` is a fast hashmap based dictionary implemnted in Mojo 🔥.

Although the dictionary is fast (currently it is about 10x faster than the std `Dict`) its main concern is with reducing memory footprint.

We introduce two self sufficient modules:
- `string_dict` where the key type of the dictionary is a `String`
- `geneic_dict` which allows keys to be of any type conforming with `Keyable` trait

Both modules expose a `Dict` struct which have following compile time parametrisation options:
- Value type can be any type conforming with `CollectionElement` trait
- We use a fast hash function as default, but you can provide your own hash function
- By setting the `KeyCountType` to a lower unsigned DType e.g. (`DType.uint8` or `DType.uint16`) we can reduce the memory footprint. The type needs to be able to represent number of keys
- By setting the `KeyOffsetType` to a lower unsigned DType we can reduce the memory footprint even further. The type needs to be able to represent the sum of all key bytes
- Set `destructive` to `False` if you don't intend to delete keys from the dict. This way we do not waste space for deleted flags
- Set `caching_hashes` to `False` in order to reduce memory footprint by not caching the hash values. Keep in mind that this change slows down the rehashing process

The `Dict` can be instatiated with a `capacity` value. Deafult is set to 16, min capacity is 8. If you know the number of elements ahead of time set it, this will avoid rehashing and might improve memory footprint.

### Sample code for generic dict:
```
from generic_dict import Dict, Keyable, KeysBuilder
from testing import assert_equal

@value
struct Person(Keyable):
    var name: String
    var age: Int

    fn accept[T: KeysBuilder](self, inout keys_builder: T):
        keys_builder.add_buffer[DType.int8](self.name._as_ptr(), len(self.name))
        keys_builder.add(Int64(self.age))

fn test_person_dict() raises:
    let p1 = Person("Maxim", 42)
    let p2 = Person("Maximilian", 62)
    let p3 = Person("Alex", 25)
    let p4 = Person("Maria", 28)
    let p5 = Person("Daria", 13)
    let p6 = Person("Max", 31)

    var d = Dict[Int]()
    d.put(p1, 1)
    d.put(p2, 11)
    d.put(p3, 111)
    d.put(p4, 1111)
    d.put(p5, 11111)
    d.put(p6, 111111)

    assert_equal(d.get(p1, 0), 1)
    assert_equal(d.get(p2, 0), 11)
    assert_equal(d.get(p3, 0), 111)
    assert_equal(d.get(p4, 0), 1111)
    assert_equal(d.get(p5, 0), 11111)
    assert_equal(d.get(p6, 0), 111111)

```
