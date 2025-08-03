import benchmark
from string_dict import Dict as CompactDict
from collections.dict import KeyElement, Dict as StdDict
from pathlib import cwd
from testing import assert_equal
from csv import CsvBuilder
from helpers.progress_bar import progress_bar
import os
from corpora import *

alias M = 9

@fieldwise_init
struct BenchmarkData(Copyable, Movable):
    var reports: List[benchmark.Report]
    var read_checksums: List[Int]

    fn __init__(out self):
        self.reports = List[benchmark.Report]()
        self.read_checksums = List[Int]()

def report_std_benchmarks(corpus: List[String], mut csv_builder: CsvBuilder) -> BenchmarkData:
    var benchmark_data = BenchmarkData()
    var std_dict = StdDict[String, Int]()
    @parameter
    fn build_dict():
        var d = StdDict[String, Int]()
        for i in range(len(corpus)):
            d[corpus[i]] = i
        std_dict = d^
    var build_stats = benchmark.run[build_dict](max_runtime_secs=0.5)
    csv_builder.push(String(build_stats.mean("ns")), False)
    benchmark_data.reports.append(build_stats)

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
    csv_builder.push(String(read_stats.mean("ns")), False)
    benchmark_data.reports.append(read_stats)
    benchmark_data.read_checksums.append(sum)

    @parameter
    fn delete_dict():
        for i in range(len(corpus)):
            if i % M == 0:
                try:
                    _ = std_dict.pop(corpus[i])
                except:
                    pass
    
    var delete_stats = benchmark.run[delete_dict](max_runtime_secs=0.5)
    csv_builder.push(String(delete_stats.mean("ns")), False)
    benchmark_data.reports.append(delete_stats)

    var read_after_delete_stats = benchmark.run[read_dict](max_runtime_secs=0.5)
    csv_builder.push(String(read_after_delete_stats.mean("ns")), False)
    benchmark_data.reports.append(read_after_delete_stats)
    benchmark_data.read_checksums.append(sum)

    _ = std_dict

    return benchmark_data


def report_compact_benchmarks(corpus: List[String], mut csv_builder: CsvBuilder) -> BenchmarkData:
    var benchmark_data = BenchmarkData()
    var dict = CompactDict[Int]()
    @parameter
    fn build_dict_nc():
        var d = CompactDict[Int]()
        for i in range(len(corpus)):
            d.put(corpus[i], i)
        dict = d^
    var build_stats_nc = benchmark.run[build_dict_nc](max_runtime_secs=0.5)
    csv_builder.push(String(build_stats_nc.mean("ns")), False)
    benchmark_data.reports.append(build_stats_nc)

    @parameter
    fn build_dict():
        var d = CompactDict[Int](len(corpus))
        for i in range(len(corpus)):
            d.put(corpus[i], i)
        dict = d^
    var build_stats = benchmark.run[build_dict](max_runtime_secs=0.5)
    csv_builder.push(String(build_stats.mean("ns")), False)
    benchmark_data.reports.append(build_stats)

    var sum = 0
    @parameter
    fn read_dict():
        sum = 0
        for i in range(len(corpus)):
            sum += dict.get(corpus[i], -1)

    var read_stats = benchmark.run[read_dict](max_runtime_secs=0.5)
#     var read_checksum = sum
    csv_builder.push(String(read_stats.mean("ns")), False)
    benchmark_data.reports.append(read_stats)
    benchmark_data.read_checksums.append(sum)

    @parameter
    fn delete_dict():
        for i in range(len(corpus)):
            if i % M == 0:
                dict.delete(corpus[i])
    
    var delete_stats = benchmark.run[delete_dict](max_runtime_secs=0.5)
    csv_builder.push(String(delete_stats.mean("ns")), False)
    benchmark_data.reports.append(delete_stats)

    var read_after_delete_stats = benchmark.run[read_dict](max_runtime_secs=0.5)
#     var read_after_delete_checksum = sum

    csv_builder.push(String(read_after_delete_stats.mean("ns")), False)
    benchmark_data.reports.append(read_after_delete_stats)
    benchmark_data.read_checksums.append(sum)
    _ = dict
    return benchmark_data

fn corpus_stats(corpus: List[String], mut csv_builder: CsvBuilder):
    csv_builder.push(String(len(corpus)), False)
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
    csv_builder.push(String(sum), False)
    csv_builder.push(String(min), False)
    csv_builder.push(String(avg), False)
    csv_builder.push(String(max), False)

fn report_speedup(std: BenchmarkData, compact: BenchmarkData, mut csv_builder: CsvBuilder):
    csv_builder.push(String(std.reports[0].mean() / compact.reports[0].mean()), False)
    csv_builder.push(String(std.reports[0].mean() / compact.reports[1].mean()), False)
    csv_builder.push(String(std.reports[1].mean() / compact.reports[2].mean()), False)
    csv_builder.push(String(std.reports[2].mean() / compact.reports[3].mean()), False)
    csv_builder.push(String(std.reports[3].mean() / compact.reports[4].mean()), False)

fn report_checksums_alignment(std: BenchmarkData, compact: BenchmarkData, mut csv_builder: CsvBuilder):
    csv_builder.push(String(std.read_checksums[0] == compact.read_checksums[0]), False)
    csv_builder.push(String(std.read_checksums[1] == compact.read_checksums[1]), False)

def report(name: String, corpus: List[String], mut csv_builder: CsvBuilder):
    csv_builder.push(name, False)
    corpus_stats(corpus, csv_builder)
    var std_stats = report_std_benchmarks(corpus, csv_builder)
    var compact_stats = report_compact_benchmarks(corpus, csv_builder)
    report_speedup(std_stats, compact_stats, csv_builder)
    report_checksums_alignment(std_stats, compact_stats, csv_builder)

fn file_exists(path: String) -> Bool:
    return os.path.exists(path)

fn main() raises:
    var csv_builder = CsvBuilder(
        "Corpus", "Number of keys", "Total bytes", "Min key", "Avg key", "Max key",
        "Build stdlib", "Read stdlib", "Delete stdlib", "Read after delete stdlib",
        "Build compact nc", "Build compact", "Read compact", "Delete compact", "Read after delete compact",
        "Speedup build nc", "Speedup build", "Speedup read", "Speadup delete", "Speedup read after delete",
        "Read Checksum", "Read Checksum after delete"
    )

    var names = [
        "Arabic", "Chinese", "English", "French",
        "Georgien", "German", "Greek", "Hebrew",
        "Hindi", "Japanese", "l33t", "Russian",
        "S3",
    ]

    var generators = [
        arabic_text_to_keys, chinese_text_to_keys, english_text_to_keys, french_text_to_keys,
        georgian_text_to_keys, german_text_to_keys, greek_text_to_keys, hebrew_text_to_keys,
        hindi_text_to_keys, japanese_long_keys, l33t_text_to_keys, russian_text_to_keys,
        s3_action_names,
    ]

    # https://unix.stackexchange.com/questions/213628/where-do-the-words-in-usr-share-dict-words-come-from/798355#798355
    var use_system_words = file_exists('/usr/share/dict/words')

    if use_system_words:
        names.append("Words")
        generators.append(system_words_collection)


    @parameter
    fn one_step(i: Int) raises:
        report(names[i], generators[i](), csv_builder)

#   Call `report("Arabic", arabic_text_to_keys(), csv_builder)` iterating over names and generators
    progress_bar[one_step](n=len(names), prefix="Corpus:", bar_size=40)

    _ = csv_builder^.finish()
    print("\n")
