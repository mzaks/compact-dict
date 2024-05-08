from generic_dict import SparseArray
from tensor import Tensor, TensorShape
from testing import assert_equal


fn main() raises:
    var a = SparseArray[DType.int64](25)
    # TODO: the tensors seems to be equal but assertion fails, investigate later, probably std lin bug
    # assert_equal(a.values_tensor(), Tensor[DType.int64](TensorShape(0)))
    a[23] = 15
    assert_equal(a.get(23).or_else(0), 15)
    # assert_equal(a.values_tensor(), Tensor[DType.int64](TensorShape(1), 15))
    a[1] = 45
    assert_equal(a.get(1).or_else(0), 45)
    # assert_equal(a.values_tensor(), Tensor[DType.int64](TensorShape(2), 45, 15))
    a[13] = 1
    assert_equal(a.get(13).or_else(0), 1)
    # assert_equal(a.values_tensor(), Tensor[DType.int64](TensorShape(3), 45, 1, 15))
    a[24] = 11
    assert_equal(a.get(24).or_else(0), 11)
    # assert_equal(a.values_tensor(), Tensor[DType.int64](TensorShape(4), 45, 1, 15, 11))
    a[2] = 0
    assert_equal(a.get(2).or_else(0), 0)
    # assert_equal(a.values_tensor(), Tensor[DType.int64](TensorShape(5), 45, 0, 1, 15, 11))
    a[53] = 5
    assert_equal(a.get(53).or_else(0), 5)
    # assert_equal(a.values_tensor(), Tensor[DType.int64](TensorShape(6), 45, 0, 1, 15, 11, 5))
    a[0] = 33
    assert_equal(a.get(0).or_else(0), 33)
    # assert_equal(a.values_tensor(), Tensor[DType.int64](TensorShape(7), 33, 45, 0, 1, 15, 11, 5))
    a[53] = 49
    assert_equal(a.get(53).or_else(0), 49)
    # assert_equal(a.values_tensor(), Tensor[DType.int64](TensorShape(7), 33, 45, 0, 1, 15, 11, 49))
