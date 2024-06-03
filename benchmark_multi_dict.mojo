import benchmark
from generic_dict import MultiDict, Keyable, KeysBuilder
from collections.dict import KeyElement, Dict as StdDict
from pathlib import cwd
from testing import assert_equal

from corpora import *


@value
struct StringKey(KeyElement, Keyable):
    var s: String

    fn __init__(inout self, owned s: String):
        self.s = s^

    fn __init__(inout self, s: StringLiteral):
        self.s = String(s)

    fn __hash__(self) -> Int:
        var ptr = self.s.unsafe_ptr()
        return hash(ptr, len(self.s))

    fn __eq__(self, other: Self) -> Bool:
        return self.s == other.s

    fn __ne__(self, other: Self) -> Bool:
        return self.s != other.s

    fn accept[T: KeysBuilder](self, inout keys_builder: T):
        keys_builder.add_buffer(self.s.unsafe_ptr(), len(self.s))

fn corpus_stats(corpus: List[String]):
    print("=======Corpus Stats=======")
    print("Number of elements:", len(corpus))
    var min = 100000000
    var max = 0
    var sum = 0
    var count = 0
    for i in range(len(corpus)):
        var key = corpus[i]
        if len(key) == 0:
            continue
        count += 1
        sum += len(key)
        if min > len(key):
            min = len(key)
        if max < len(key):
            max = len(key)
    var avg = sum / count
    print("Min key lenght:", min)
    print("Avg key length:", avg)
    print("Max key length:", max)
    print("Total num of bytes:", sum)
    print("\n")

fn main() raises:
    var d1 = MultiDict[Int]()
    var d2 = StdDict[StringKey, Int]()
    var corpus = french_text_to_keys()
    
    print("")
    corpus_stats(corpus)

    @parameter
    fn build_compact_dict():
        var d = MultiDict[Int](len(corpus))
        # var d = MultiDict[Int]()
        for i in range(len(corpus)):
            try:
                d.put(StringKey(corpus[i]), i)
            except:
                print("!!!")
        d1 = d^

    @parameter
    fn build_std_dict():
        var d = StdDict[StringKey, Int]()
        for i in range(len(corpus)):
            d[corpus[i]] = i
        d2 = d^

    print("+++++++Create Dict Benchmark+++++++")

    var build_compact_stats = benchmark.run[build_compact_dict](max_runtime_secs=0.5)
    # build_compact_stats.print("ns")

    var build_std_stats = benchmark.run[build_std_dict](max_runtime_secs=0.5)
    # build_std_stats.print("ns")

    print("Compact build speedup:", build_std_stats.mean() / build_compact_stats.mean())
    var sum1 = 0
    @parameter
    fn read_compact_dict():
        sum1 = 0
        for i in range(len(corpus)):
            try:
                var v = d1.get(StringKey(corpus[i]))
                sum1 += v[len(v) - 1]
            except:
                print("!!!!!")

    # d1.keys.print_keys()
    print("+++++++Read Dict Benchmark+++++++")
    var read_compact_stats = benchmark.run[read_compact_dict](max_runtime_secs=0.5)
    print("Sum1:", sum1, len(d1))
    # read_compact_stats.print("ns")

    var sum2 = 0
    @parameter
    fn read_std_dict():
        sum2 = 0
        for i in range(len(corpus)):
            try:
                sum2 += d2[corpus[i]]
            except:
                sum2 += -1

    var raed_std_stats = benchmark.run[read_std_dict](max_runtime_secs=0.5)
    # raed_std_stats.print("ns")
    print("Sum2:", sum2, len(d2))
    print("Compact read speedup:", raed_std_stats.mean() / read_compact_stats.mean())
    
    assert_equal(sum1, sum2)
    assert_equal(len(d1), len(d2))

    _ = corpus
    _ = d1^
    _ = d2^