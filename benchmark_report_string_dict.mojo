import benchmark
from string_dict import Dict as CompactDict
from collections.dict import KeyElement, Dict as StdDict
from pathlib import cwd
from testing import assert_equal
from csv import CsvBuilder

from corpora import *

alias M = 9

@value
struct BenchmarkData:
    var reports: DynamicVector[benchmark.Report]
    var read_checksums: DynamicVector[Int]

    fn __init__(inout self):
        self.reports = DynamicVector[benchmark.Report]()
        self.read_checksums = DynamicVector[Int]()

fn report_std_benchmarks(corpus: DynamicVector[String], inout csv_builder: CsvBuilder) -> BenchmarkData:
    var benchmark_data = BenchmarkData()
    var std_dict = StdDict[String, Int]()
    @parameter
    fn build_dict():
        var d = StdDict[String, Int]()
        for i in range(len(corpus)):
            d[corpus[i]] = i
        std_dict = d^
    var build_stats = benchmark.run[build_dict](max_runtime_secs=0.5)
    csv_builder.push(build_stats.mean("ns"), False)
    benchmark_data.reports.push_back(build_stats)

    var sum = 0
    @parameter
    fn read_dict():
        sum = 0
        for i in range(len(corpus)):
            try:
                sum += std_dict[corpus[i]]
            except:
                sum += -1

    var read_stats = benchmark.run[read_dict](max_runtime_secs=0.5)
    csv_builder.push(read_stats.mean("ns"), False)
    benchmark_data.reports.push_back(read_stats)
    benchmark_data.read_checksums.push_back(sum)

    @parameter
    fn delete_dict():
        for i in range(len(corpus)):
            if i % M == 0:
                try:
                    _ = std_dict.pop(corpus[i])
                except:
                    pass
    
    var delete_stats = benchmark.run[delete_dict](max_runtime_secs=0.5)
    csv_builder.push(delete_stats.mean("ns"), False)
    benchmark_data.reports.push_back(delete_stats)

    var read_after_delete_stats = benchmark.run[read_dict](max_runtime_secs=0.5)
    csv_builder.push(read_after_delete_stats.mean("ns"), False)
    benchmark_data.reports.push_back(read_after_delete_stats)
    benchmark_data.read_checksums.push_back(sum)

    return benchmark_data


fn report_compact_benchmarks(corpus: DynamicVector[String], inout csv_builder: CsvBuilder) -> BenchmarkData:
    var benchmark_data = BenchmarkData()
    var dict = CompactDict[Int]()
    @parameter
    fn build_dict_nc():
        var d = CompactDict[Int]()
        for i in range(len(corpus)):
            d.put(corpus[i], i)
        dict = d^
    var build_stats_nc = benchmark.run[build_dict_nc](max_runtime_secs=0.5)
    csv_builder.push(build_stats_nc.mean("ns"), False)
    benchmark_data.reports.push_back(build_stats_nc)

    @parameter
    fn build_dict():
        var d = CompactDict[Int](len(corpus))
        for i in range(len(corpus)):
            d.put(corpus[i], i)
        dict = d^
    var build_stats = benchmark.run[build_dict](max_runtime_secs=0.5)
    csv_builder.push(build_stats.mean("ns"), False)
    benchmark_data.reports.push_back(build_stats)

    var sum = 0
    @parameter
    fn read_dict():
        sum = 0
        for i in range(len(corpus)):
            sum += dict.get(corpus[i], -1)

    var read_stats = benchmark.run[read_dict](max_runtime_secs=0.5)
    var read_checksum = sum
    csv_builder.push(read_stats.mean("ns"), False)
    benchmark_data.reports.push_back(read_stats)
    benchmark_data.read_checksums.push_back(sum)

    @parameter
    fn delete_dict():
        for i in range(len(corpus)):
            if i % M == 0:
                dict.delete(corpus[i])
    
    var delete_stats = benchmark.run[delete_dict](max_runtime_secs=0.5)
    csv_builder.push(delete_stats.mean("ns"), False)
    benchmark_data.reports.push_back(delete_stats)

    var read_after_delete_stats = benchmark.run[read_dict](max_runtime_secs=0.5)
    var read_after_delete_checksum = sum

    csv_builder.push(read_after_delete_stats.mean("ns"), False)
    benchmark_data.reports.push_back(read_after_delete_stats)
    benchmark_data.read_checksums.push_back(sum)
    
    return benchmark_data

fn corpus_stats(corpus: DynamicVector[String], inout csv_builder: CsvBuilder):
    csv_builder.push(len(corpus), False)
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
    csv_builder.push(sum, False)
    csv_builder.push(min, False)
    csv_builder.push(avg, False)
    csv_builder.push(max, False)

fn report_speedup(std: BenchmarkData, compact: BenchmarkData, inout csv_builder: CsvBuilder):
    csv_builder.push(std.reports[0].mean() / compact.reports[0].mean(), False)
    csv_builder.push(std.reports[0].mean() / compact.reports[1].mean(), False)
    csv_builder.push(std.reports[1].mean() / compact.reports[2].mean(), False)
    csv_builder.push(std.reports[2].mean() / compact.reports[3].mean(), False)
    csv_builder.push(std.reports[3].mean() / compact.reports[4].mean(), False)

fn report_checksums_alignment(std: BenchmarkData, compact: BenchmarkData, inout csv_builder: CsvBuilder):
    csv_builder.push(std.read_checksums[0] == compact.read_checksums[0], False)
    csv_builder.push(std.read_checksums[1] == compact.read_checksums[1], False)

fn report(name: StringLiteral, corpus: DynamicVector[String], inout csv_builder: CsvBuilder):
    csv_builder.push(name, False)
    corpus_stats(corpus, csv_builder)
    var std_stats = report_std_benchmarks(corpus, csv_builder)
    var compact_stats = report_compact_benchmarks(corpus, csv_builder)
    report_speedup(std_stats, compact_stats, csv_builder)
    report_checksums_alignment(std_stats, compact_stats, csv_builder)

fn main() raises:
    var csv_builder = CsvBuilder(
        "Corpus", "Number of keys", "Total bytes", "Min key", "Avg key", "Max key", 
        "Build stdlib", "Read stdlib", "Delete stdlib", "Read after delete stdlib",
        "Build compact nc", "Build compact", "Read compact", "Delete compact", "Read after delete compact",
        "Speedup build nc", "Speedup build", "Speedup read", "Speadup delete", "Speedup read after delete",
        "Read Checksum", "Read Checksum after delete"
    )
    report("Arabic", arabic_text_to_keys(), csv_builder)
    report("Chinese", chinese_text_to_keys(), csv_builder)
    report("English", english_text_to_keys(), csv_builder)
    report("French", french_text_to_keys(), csv_builder)
    report("Georgien", georgian_text_to_keys(), csv_builder)
    report("German", german_text_to_keys(), csv_builder)
    report("Greek", greek_text_to_keys(), csv_builder)
    report("Hebrew", hebrew_text_to_keys(), csv_builder)
    # Bug on intel i7 Mojo 24.1.1
    # report("Hindi", hindi_text_to_keys(), csv_builder)
    report("Japanese", japanese_long_keys(), csv_builder)
    report("l33t", l33t_text_to_keys(), csv_builder)
    # Bug on intel i7 Mojo 24.1.1
    # report("Russian", russian_text_to_keys(), csv_builder)
    report("S3", s3_action_names(), csv_builder)
    report("Words", system_words_collection(), csv_builder)
    print(csv_builder^.finish())