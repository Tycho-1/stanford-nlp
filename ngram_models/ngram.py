from random import randrange
from collections import defaultdict
from functools import reduce
import operator
from math import log2

def _prod(iterable):
    return reduce(operator.mul, iterable, 1)

class MultinomialModel:
    def __init__(self):
        self._counts = defaultdict(int)
        self._total = 0

    def train(self, word):
        self._counts[word] += 1
        self._total += 1
        return self

    def prob(self, word):
        return self._counts[word] / self._total

    def sample(self):
        # We are going to make use of the (language, not CPython)
        # guarantee that dicts preserve iteration order if no
        # insertions or deletions have occurred. If the ordering
        # was not constant, and the changes correlated with random
        # number generation, then the sampling would be biased.

        target_count = randrange(self._total)
        cumulative_count = 0
        for word, count in self._counts.items():
            cumulative_count += count
            if target_count < cumulative_count:
                return word


_START = -1
_STOP = -2

class NGramModel:

    def __init__(self, n):
        self._n = n
        self._conditionedProbs = defaultdict(MultinomialModel)
        self._total = 0

    def _ngrams(self, sentence):
        CONDITION_SZ = self._n - 1
        padded_sentence = [_START] * CONDITION_SZ + sentence + [_STOP]
        for idx in range(CONDITION_SZ, len(padded_sentence)):
            condition_words = padded_sentence[idx - CONDITION_SZ:idx]
            curr_word = padded_sentence[idx]
            yield (tuple(condition_words), curr_word)

    def train(self, sentence):
        for condition, word in self._ngrams(sentence):
            self._conditionedProbs[condition].train(word)

    def logprob(self, sentence):
        logprobs = [log2(self._conditionedProbs[condition].prob(word))
                    for condition, word in self._ngrams(sentence)]
        return sum(logprobs)

    def perplexity(self, sentences):
        LEN_STOP = 1
        total_len = sum(len(sentence) + LEN_STOP for sentence in sentences)
        sum_logprobs = sum(self.logprob(sentence) for sentence in sentences)
        logperplexity = -sum_logprobs / total_len
        return 2**logperplexity

    def visualise(self):
        sentence = []
        CONDITION_SZ = self._n - 1
        condition = (_START,) * CONDITION_SZ
        while True:
            curr_word = self._conditionedProbs[condition].sample()
            if curr_word == _STOP:
                break
            sentence.append(curr_word)
            condition = (condition + (curr_word,))[1:]
        return sentence
