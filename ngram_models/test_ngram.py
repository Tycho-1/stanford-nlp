import unittest

from ngram import NGramModel
from ngram import MultinomialModel

class MultinomialModelTestCase(unittest.TestCase):
    def test_conditioned_prob_(self):
        multinomial = MultinomialModel()
        multinomial.train('a').train(1).train('a')
        self.assertEqual(multinomial.prob('a'), 2/3)
        self.assertEqual(multinomial.prob(1), 1/3)
        

class NGramModelTestCase(unittest.TestCase):
    def test_unigram_logprob_of_single_word_sentences(self):
        model = NGramModel(1)
        model.train(['i', 'like', 'really', 'like', 'really', 'fast', 'ham'])
        self.assertEqual(model.logprob(['i']), -6)
        self.assertEqual(model.logprob(['really']), -5)

    def test_unigram_logprob_of_multiple_word_sentences(self):
        model = NGramModel(1)
        model.train(['i', 'like', 'really', 'like', 'really', 'fast', 'ham'])
        self.assertEqual(model.logprob(['i', 'really']), -8)
        self.assertEqual(model.logprob(['really', 'really']), -7)

    def test_unigram_perplexity(self):
        model = NGramModel(1)
        model.train(['i', 'move', 'slowly'])
        self.assertEqual(model.perplexity([['move']]), 4)

    def test_bigram_logprob_of_single_word_sentences(self):
        model = NGramModel(2)
        model.train(['i', 'like', 'really', 'like', 'really', 'fast', 'ham'])
        model.train(['i'])
        self.assertEqual(model.logprob(['i']), -1)
