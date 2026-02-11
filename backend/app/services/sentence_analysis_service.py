import spacy

class SentenceAnalysisService:
    def __init__(self):
        self.nlp = spacy.load("fi_core_news_sm")

    def segment_sentences(self, text: str):
        doc = self.nlp(text)
        sentences = [sent.text for sent in doc.sents]
        return sentences
