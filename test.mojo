from compact_dict import Dict
from testing import assert_equal

from corpora import *

fn test_simple_manipulations() raises:
    var d = Dict[Int, KeyCountType=DType.uint8, KeyOffsetType=DType.uint16]()
    let corpus = s3_action_names()
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
    let corpus = s3_action_names()
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
    let corpus = s3_action_names()
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

fn main()raises:
    test_simple_manipulations()
    test_simple_manipulations_on_non_destructive()
    test_simple_manipulations_non_caching()