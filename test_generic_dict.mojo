from generic_dict import Dict, Keyable, KeysBuilder
from testing import assert_equal

from corpora import *

@fieldwise_init
struct Person(Keyable, Copyable, Movable):
    var name: String
    var age: Int

    fn accept[T: KeysBuilder](self, mut keys_builder: T):
        keys_builder.add_buffer[DType.uint8](self.name.unsafe_ptr(), len(self.name))
        keys_builder.add(Int64(self.age))

fn test_person_dict() raises:
    var p1 = Person("Maxim", 42)
    var p2 = Person("Maximilian", 62)
    var p3 = Person("Alex", 25)
    var p4 = Person("Maria", 28)
    var p5 = Person("Daria", 13)
    var p6 = Person("Max", 31)

    var d = Dict[Int]()
    _= d.put(p1, 1)
    _= d.put(p2, 11)
    _= d.put(p3, 111)
    _= d.put(p4, 1111)
    _= d.put(p5, 11111)
    _= d.put(p6, 111111)

    assert_equal(d.get(p1, 0), 1)
    # assert_equal(d.get(p2, 0), 11)
    # assert_equal(d.get(p3, 0), 111)
    # assert_equal(d.get(p4, 0), 1111)
    # assert_equal(d.get(p5, 0), 11111)
    # assert_equal(d.get(p6, 0), 111111)

struct StringKey(Keyable, Copyable, Movable):
    var s: String

    fn __init__(out self, owned s: String):
        self.s = s^

    fn __init__(out self, s: StringLiteral):
        self.s = String(s)

    fn accept[T: KeysBuilder](self, mut keys_builder: T):
        alias type_prefix = "String:"
        keys_builder.add_buffer(type_prefix.unsafe_ptr(), len(type_prefix))
        keys_builder.add_buffer(self.s.unsafe_ptr(), len(self.s))

struct IntKey(Keyable, Copyable, Movable):
    var i: Int

    fn __init__(out self, i: Int):
        self.i = i

    fn accept[T: KeysBuilder](self, mut keys_builder: T):
        alias type_prefix = "Int:"
        keys_builder.add_buffer(type_prefix.unsafe_ptr(), len(type_prefix))
        keys_builder.add(Int64(self.i))

fn test_add_vs_update() raises:
    var d = Dict[Int]()
    assert_equal(d.put(StringKey("a"), 1), True)
    assert_equal(d.put(StringKey("a"), 2), False)
    d.delete(StringKey("a"))
    assert_equal(d.put(StringKey("a"), 3), True)
    assert_equal(d.put(StringKey("a"), 4), False)
    assert_equal(d.get(StringKey("a"), 0), 4)

fn test_clear() raises:
    var d = Dict[Int]()
    assert_equal(d.put(StringKey("a"), 1), True)
    assert_equal(d.put(StringKey("b"), 1), True)
    assert_equal(d.put(StringKey("a"), 2), False)
    assert_equal(d.get(StringKey("a"), 0), 2)
    d.clear()
    assert_equal(d.put(StringKey("a"), 3), True)
    assert_equal(d.get(StringKey("a"), 0), 3)
    assert_equal(d.get(StringKey("b"), 0), 0)

fn test_no_key_collision() raises:
    var d = Dict[Int]()
    assert_equal(d.put(StringKey("a"), 1), True)
    assert_equal(d.put(IntKey(97), 2), True)
    assert_equal(d.get(StringKey("a"), 0), 1)
    assert_equal(d.get(IntKey(97), 0), 2)


fn main() raises:
    test_person_dict()
    test_add_vs_update()
    test_clear()
    test_no_key_collision()
