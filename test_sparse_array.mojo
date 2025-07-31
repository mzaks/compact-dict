from generic_dict import SparseArray
from testing import assert_equal, assert_true


fn assert_equal_list[T: DType](lhs: List[Scalar[T]], rhs: List[Scalar[T]]) raises:
    assert_equal(len(lhs), len(rhs))
    for i in range(len(lhs)):
        assert_true(lhs[i] == rhs[i])


fn main() raises:
    var a = SparseArray[DType.int64](25)
    assert_equal(len(a.dense_values_list()), 0)
    a[23] = 15
    assert_equal(a.get(23).or_else(0), 15)
    assert_equal_list[DType.int64](a.dense_values_list(), List[Int64](15))
    a[1] = 45
    assert_equal(a.get(1).or_else(0), 45)
    assert_equal_list[DType.int64](a.dense_values_list(), List[Int64](45, 15))
    a[13] = 1
    assert_equal(a.get(13).or_else(0), 1)
    assert_equal_list[DType.int64](a.dense_values_list(), List[Int64](45, 1, 15))
    a[24] = 11
    assert_equal(a.get(24).or_else(0), 11)
    assert_equal_list[DType.int64](a.dense_values_list(), List[Int64](45, 1, 15, 11))
    a[2] = 0
    assert_equal(a.get(2).or_else(0), 0)
    assert_equal_list[DType.int64](a.dense_values_list(), List[Int64](45, 0, 1, 15, 11))
    a[53] = 5
    assert_equal(a.get(53).or_else(0), 5)
    assert_equal_list[DType.int64](a.dense_values_list(), List[Int64](45, 0, 1, 15, 11, 5))
    a[0] = 33
    assert_equal(a.get(0).or_else(0), 33)
    assert_equal_list[DType.int64](a.dense_values_list(), List[Int64](33, 45, 0, 1, 15, 11, 5))
    a[53] = 49
    assert_equal(a.get(53).or_else(0), 49)
    assert_equal_list[DType.int64](a.dense_values_list(), List[Int64](33, 45, 0, 1, 15, 11, 49))
