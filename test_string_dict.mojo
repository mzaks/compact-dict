from string_dict import Dict
from testing import assert_equal

from corpora import *

fn test_simple_manipulations() raises:
    var d = Dict[Int, KeyCountType=DType.uint8, KeyOffsetType=DType.uint16]()
    var corpus = s3_action_names()
    for i in range(len(corpus)):
        d.put(corpus[i], i)
    
    assert_equal(len(d), 143)
    assert_equal(d.get("CopyObject", -1), 2)
    
    d.delete("CopyObject")
    assert_equal(d.get("CopyObject", -1), -1)
    assert_equal(len(d), 142)
    
    d.put("CopyObjects", 256)
    assert_equal(d.get("CopyObjects", -1), 256)
    assert_equal(d.get("CopyObject", -1), -1)
    assert_equal(len(d), 143)

    d.put("CopyObject", 257)
    assert_equal(d.get("CopyObject", -1), 257)
    assert_equal(len(d), 144)

    _ = d

fn test_simple_manipulations_on_non_destructive() raises:
    var d = Dict[Int, KeyCountType=DType.uint8, KeyOffsetType=DType.uint16, destructive=False]()
    var corpus = s3_action_names()
    for i in range(len(corpus)):
        d.put(corpus[i], i)
    
    assert_equal(len(d), 143)
    assert_equal(d.get("CopyObject", -1), 2)
    
    d.delete("CopyObject")
    assert_equal(d.get("CopyObject", -1), 2)
    assert_equal(len(d), 143)
    
    d.put("CopyObjects", 256)
    assert_equal(d.get("CopyObjects", -1), 256)
    assert_equal(d.get("CopyObject", -1), 2)
    assert_equal(len(d), 144)

    d.put("CopyObject", 257)
    assert_equal(d.get("CopyObject", -1), 257)
    assert_equal(len(d), 144)

fn test_simple_manipulations_non_caching() raises:
    var d = Dict[
        Int, 
        KeyCountType=DType.uint8, 
        KeyOffsetType=DType.uint16, 
        caching_hashes=False
    ]()
    var corpus = s3_action_names()
    for i in range(len(corpus)):
        d.put(corpus[i], i)
    assert_equal(len(d), 143)
    assert_equal(d.get("CopyObject", -1), 2)
    
    d.delete("CopyObject")
    assert_equal(d.get("CopyObject", -1), -1)
    assert_equal(len(d), 142)
    
    d.put("CopyObjects", 256)
    assert_equal(d.get("CopyObjects", -1), 256)
    assert_equal(d.get("CopyObject", -1), -1)
    assert_equal(len(d), 143)

    d.put("CopyObject", 257)
    assert_equal(d.get("CopyObject", -1), 257)
    assert_equal(len(d), 144)

    _ = d

@fieldwise_init
struct MyInt(Copyable, Movable):
    var value: Int

fn test_upsert() raises:
    var d1 = Dict[MyInt, KeyCountType=DType.uint8, KeyOffsetType=DType.uint16]()
    var corpus = s3_action_names()
    
    fn inc(value: Optional[MyInt]) -> MyInt:
        return MyInt(value.or_else(MyInt(0)).value + 1)

    for i in range(len(corpus)):
        d1.upsert(corpus[i], inc)

    # Does not work probably because of Int is a register passable type
    # var d2 = Dict[Int, KeyCountType=DType.uint8, KeyOffsetType=DType.uint16]()

    # fn inc2(value: Optional[Int]) -> Int:
    #     return value.or_else(0) + 1

    # for i in range(len(corpus)):
    #     d2.upsert(corpus[i], inc2) 

fn test_clear() raises:
    var d = Dict[Int]()
    d.put("a", 1)
    d.put("b", 1)
    assert_equal(d.get("a", 0), 1)
    assert_equal(d.get("b", 0), 1)
    d.clear()
    d.put("a", 2)
    assert_equal(d.get("a", 0), 2)
    assert_equal(d.get("b", 0), 0)


fn main()raises:
    test_simple_manipulations()
    test_simple_manipulations_on_non_destructive()
    test_simple_manipulations_non_caching()
    test_upsert()
    test_clear()
