import benchmark
from string_dict import Dict
from collections.dict import KeyElement, Dict as StdDict
from pathlib import cwd
from testing import assert_equal

from corpora import *


fn corpus_stats(corpus: DynamicVector[String]):
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
    var d1 = Dict[Int]()
    var d2 = StdDict[String, Int]()
    var corpus = french_text_to_keys()
    
    print("")
    corpus_stats(corpus)

    @parameter
    fn build_compact_dict():
        var d = Dict[Int](len(corpus))
        # var d = Dict[Int]()
        for i in range(len(corpus)):
            d.put(corpus[i], i)
        d1 = d^

    @parameter
    fn build_std_dict():
        var d = StdDict[String, Int]()
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
            sum1 += d1.get(corpus[i], -1)

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

    var m = 9
    @parameter
    fn delete_compact_dict():
        for i in range(len(corpus)):
            if i % m == 0:
                d1.delete(corpus[i])

    @parameter
    fn delete_std_dict():
        for i in range(len(corpus)):
            if i % m == 0:
                try:
                    _ = d2.pop(corpus[i])
                except:
                    pass

    print("+++++++Delete Dict Benchmark+++++++")

    var delete_compact_stats = benchmark.run[delete_compact_dict](max_runtime_secs=0.5)
    var delete_std_stats = benchmark.run[delete_std_dict](max_runtime_secs=0.5)

    print("Compact delete speedup:", delete_std_stats.mean() / delete_compact_stats.mean())

    print("+++++++Read After Delete Dict Benchmark+++++++")

    var read_after_delete_compact_stats = benchmark.run[read_compact_dict](max_runtime_secs=0.5)
    var read_after_delete_std_stats = benchmark.run[read_std_dict](max_runtime_secs=0.5)

    print("Compact read after delete speedup:", read_after_delete_std_stats.mean() / read_after_delete_compact_stats.mean())

    print("Sum1:", sum1, "length:", len(d1))
    print("Sum2:", sum2, "length:", len(d2))

    assert_equal(sum1, sum2)
    assert_equal(len(d1), len(d2))

    _ = corpus
    _ = d1^
    _ = d2^