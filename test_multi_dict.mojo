from generic_dict import MultiDict, Keyable, KeysBuilder
from testing import assert_equal

from corpora import *

struct StringKey(Keyable, Copyable, Movable):
    var s: String

    fn __init__(out self, owned s: String):
        self.s = s^

    fn __init__(out self, s: StringLiteral):
        self.s = String(s)

    fn accept[T: KeysBuilder](self, mut keys_builder: T):
        keys_builder.add_buffer(self.s.unsafe_ptr(), len(self.s))

fn test_add() raises:
    var d = MultiDict[Int]()
    d.put(StringKey("a"), 1)
    d.put(StringKey("b"), 2)
    d.put(StringKey("c"), 3)
    d.put(StringKey("a"), 4)
    d.put(StringKey("a"), 5)
    d.put(StringKey("a"), 6)
    d.put(StringKey("c"), 7)

    assert_equal(len(d.get(StringKey("a"))), 4)
    assert_equal(d.get(StringKey("a"))[0], 1)
    assert_equal(d.get(StringKey("a"))[1], 4)
    assert_equal(d.get(StringKey("a"))[2], 5)
    assert_equal(d.get(StringKey("a"))[3], 6)
    assert_equal(len(d.get(StringKey("b"))), 1)
    assert_equal(d.get(StringKey("b"))[0], 2)
    assert_equal(len(d.get(StringKey("c"))), 2)
    assert_equal(d.get(StringKey("c"))[0], 3)
    assert_equal(d.get(StringKey("c"))[1], 7)

fn test_s3_corpus() raises:
    var d = MultiDict[
        Int,
        KeyCountType=DType.uint8,
        KeyOffsetType=DType.uint16,
        NextKeyCountType=DType.uint8
    ]()
    var corpus = s3_action_names()
    for i in range(len(corpus)):
        d.put(StringKey(corpus[i]), i)

    assert_equal(len(d), 143)

    var all_values = 0
    for i in range(len(corpus)):
        var v = d.get(StringKey(corpus[i]))
        var c = len(v)
        all_values += c

    assert_equal(all_values, 143 + (len(corpus) - 143) * 3)
    _ = d

fn test_system_corpus() raises:
    var d = MultiDict[Int]()
    var corpus = system_words_collection()
    for i in range(len(corpus)):
        d.put(StringKey(corpus[i]), i)

    assert_equal(len(d), len(corpus))

    var all_values = 0
    for i in range(len(corpus)):
        var v = d.get(StringKey(corpus[i]))
        var c = len(v)
        all_values += c

    assert_equal(all_values, len(corpus))
    _ = d

fn test_english_corpus() raises:
    var d = MultiDict[
        Int,
        KeyCountType=DType.uint16,
        KeyOffsetType=DType.uint16,
        NextKeyCountType=DType.uint16
    ]()
    var corpus = english_text_to_keys()
    for i in range(len(corpus)):
        d.put(StringKey(corpus[i]), i)
    assert_equal(len(d), 192)

    var all_values = 0
    for i in range(len(corpus)):
        var v = d.get(StringKey(corpus[i]))
        var c = len(v)
        all_values += c

    assert_equal(all_values, 18631)

    var the_occurances = 0
    for i in range(len(corpus)):
        if corpus[i] == "the":
            the_occurances += 1
    assert_equal(len(d.get(StringKey("the"))), the_occurances)
    _ = d

fn test_get_itter() raises:
    var d = MultiDict[Int]()
    d.put(StringKey("a"), 1)
    d.put(StringKey("b"), 2)
    d.put(StringKey("c"), 3)
    d.put(StringKey("a"), 4)
    d.put(StringKey("a"), 5)
    d.put(StringKey("a"), 6)
    d.put(StringKey("c"), 7)

    var index_a = 0
    var expected_a = List[Int](1, 4, 5, 6)
    for v in d.get_itter(StringKey("a")):
        assert_equal(expected_a[index_a], v)
        index_a += 1

    assert_equal(index_a, 4)

    var index_b = 0
    var expected_b = List[Int](2)
    for v in d.get_itter(StringKey("b")):
        assert_equal(expected_b[index_b], v)
        index_b += 1
    assert_equal(index_b, 1)

    var index_c = 0
    var expected_c = List[Int](3, 7)
    for v in d.get_itter(StringKey("c")):
        assert_equal(expected_c[index_c], v)
        index_c += 1
    assert_equal(index_c, 2)

    var index_d = 0
    var expected_d = List[Int](2)
    for v in d.get_itter(StringKey("d")):
        print(v)
        assert_equal(expected_d[index_d], v)
        index_d += 1
    assert_equal(index_d, 0)

fn main()raises:
    test_add()
    test_s3_corpus()
    test_system_corpus()
    test_english_corpus()
    test_get_itter()
