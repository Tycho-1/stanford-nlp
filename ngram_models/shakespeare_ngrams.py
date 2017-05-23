import random as rand

from ngram import NGramModel

WORDS_FILE = 'words.txt'
END_SENTENCE = '*'

models = [NGramModel(n) for n in [1, 2, 3, 4]]

def shakespeare_sentences(open_file):
    sentence = []
    for line in open_file:
        word = line.strip()
        if word == END_SENTENCE:
            if len(sentence) > 0:
                yield sentence
            sentence = []
        elif word:
            sentence.append(word)

def split_data(sentences, test_ratio, cross_val_ratio=0):
    train = []
    cross_val = []
    test = []
    test_cutoff = test_ratio
    cross_val_cutoff = test_cutoff + cross_val_ratio
    for sentence in sentences:
        bucket = rand.random()
        if bucket < test_cutoff:
            test.append(sentence)
        elif bucket < cross_val_cutoff:
            cross_val.append(sentence)
        else:
            train.append(sentence)

    return (train, cross_val, test)


train, cross_val, test = (None, None, None)

with open(WORDS_FILE) as fp:
    train, cross_val, test = split_data(shakespeare_sentences(fp),
                                        test_ratio=0.0, cross_val_ratio=0)

for model in models:
    for sentence in train:
        model.train(sentence)
