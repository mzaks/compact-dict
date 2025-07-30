`compact-dict` is a fast hashmap based dictionary implemented in Mojo 🔥.

Although the dictionary is fast (currently it is about 10x faster than the std `Dict`) its main concern is with reducing memory footprint.

We introduce two self-sufficient modules:
- `string_dict` where the key type of the dictionary is a `String`
- `generic_dict` which allows keys to be of any type conforming with `Keyable` trait

Both modules expose a `Dict` struct which has the following compile time parametrization options:
- Value type can be any type conforming with `CollectionElement` trait
- We use a fast hash function as default, but you can provide your own hash function
- By setting the `KeyCountType` to a lower unsigned DType e.g. (`DType.uint8` or `DType.uint16`) we can reduce the memory footprint. The type needs to be able to represent number of keys
- By setting the `KeyOffsetType` to a lower unsigned DType we can reduce the memory footprint even further. The type needs to be able to represent the sum of all key bytes
- Set `destructive` to `False` if you don't intend to delete keys from the dict. This way we do not waste space for deleted flags
- Set `caching_hashes` to `False` in order to reduce memory footprint by not caching the hash values. Keep in mind that this change slows down the rehashing process

The `Dict` can be instantiated with a `capacity` value. Default is set to 16, min capacity is 8. If you know the number of elements ahead of time set it, this will avoid rehashing and might improve memory footprint.

### Sample code for generic dict:
```
from generic_dict import Dict, Keyable, KeysBuilder
from testing import assert_equal

@fieldwise_init
struct Person(Keyable, Copyable, Movable):
    var name: String
    var age: Int

    fn accept[T: KeysBuilder](self, mut keys_builder: T):
        keys_builder.add_buffer[DType.uint8](self.name.unsafe_ptr(), len(self.name))
        keys_builder.add(Int64(self.age))

fn main() raises:
    var p1 = Person("Maxim", 42)
    var p2 = Person("Maximilian", 62)
    var p3 = Person("Alex", 25)
    var p4 = Person("Maria", 28)
    var p5 = Person("Daria", 13)
    var p6 = Person("Max", 31)

    var d = Dict[Int]()
    _ = d.put(p1, 1)
    _ = d.put(p2, 11)
    _ = d.put(p3, 111)
    _ = d.put(p4, 1111)
    _ = d.put(p5, 11111)
    _ = d.put(p6, 111111)

    assert_equal(d.get(p1, 0), 1)
    assert_equal(d.get(p2, 0), 11)
    assert_equal(d.get(p3, 0), 111)
    assert_equal(d.get(p4, 0), 1111)
    assert_equal(d.get(p5, 0), 11111)
    assert_equal(d.get(p6, 0), 111111)
```

### Note:
To run all tests and benchmarks, call:

```bash
make test
```

and

```bash
make benchmark 
```

for `memory` test you need to install `words` package proper for your distro: https://unix.stackexchange.com/questions/213628/where-do-the-words-in-usr-share-dict-words-come-from/798355#798355

```bash
make memory 
```