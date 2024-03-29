from generic_dict import Dict, Keyable, KeysBuilder
from testing import assert_equal

from corpora import *

@value
struct Person(Keyable):
    var name: String
    var age: Int

    fn accept[T: KeysBuilder](self, inout keys_builder: T):
        keys_builder.add_buffer[DType.int8](self.name._as_ptr(), len(self.name))
        keys_builder.add(Int64(self.age))

fn test_person_dict() raises:
    var p1 = Person("Maxim", 42)
    var p2 = Person("Maximilian", 62)
    var p3 = Person("Alex", 25)
    var p4 = Person("Maria", 28)
    var p5 = Person("Daria", 13)
    var p6 = Person("Max", 31)

    var d = Dict[Int]()
    d.put(p1, 1)
    d.put(p2, 11)
    d.put(p3, 111)
    d.put(p4, 1111)
    d.put(p5, 11111)
    d.put(p6, 111111)

    assert_equal(d.get(p1, 0), 1)
    # assert_equal(d.get(p2, 0), 11)
    # assert_equal(d.get(p3, 0), 111)
    # assert_equal(d.get(p4, 0), 1111)
    # assert_equal(d.get(p5, 0), 11111)
    # assert_equal(d.get(p6, 0), 111111)

fn main()raises:
    test_person_dict()