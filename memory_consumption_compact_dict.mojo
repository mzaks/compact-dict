from string_dict import Dict
from corpora import system_words_collection, hindi_text_to_keys

fn main() raises:
    var corpus = system_words_collection()
    var dict = Dict[Int](len(corpus))
    for _ in range(100):
        for i in range(len(corpus)):
            dict.put(corpus[i], i)

    var sum = 0
    for _ in range(100):
        sum = 0
        for i in range(len(corpus)):
            sum += dict.get(corpus[i], -1)
    
    print(sum)
