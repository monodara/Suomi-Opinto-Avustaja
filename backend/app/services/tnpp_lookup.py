import stanza
import os
import logging
from stanza import DownloadMethod

logger = logging.getLogger(__name__)

class TnppLookupService:
    def __init__(self):
        self.nlp = None
        self._init_nlp()

    def _init_nlp(self) -> None:
        if self.nlp is not None:
            return
        
        try:
            # Use REUSE_RESOURCES to avoid re-downloading if model already exists
            self.nlp = stanza.Pipeline("fi", processors="tokenize,pos,lemma", use_gpu=False, download_method=DownloadMethod.REUSE_RESOURCES)
        except Exception as e:
            # If model is not found despite reuse setting, download it, then create pipeline
            if "not found" in str(e).lower() or "download" in str(e).lower():
                logger.info("Finnish language model not found, downloading...")
                try:
                    stanza.download("fi", verbose=False)
                    self.nlp = stanza.Pipeline("fi", processors="tokenize,pos,lemma", use_gpu=False, download_method=DownloadMethod.REUSE_RESOURCES)
                    logger.info("Finnish language model downloaded and loaded successfully.")
                except Exception as download_error:
                    logger.error(f"Failed to download Finnish language model: {download_error}")
                    self.nlp = None
            else:
                logger.error(f"Error initializing Stanza pipeline: {e}")
                self.nlp = None

    def analyze_finnish_word(self, word: str):
        if not word:
            return {
                "original": word,
                "lemma": word,
                "part_of_speech": None,
                "features": None
            }
        if self.nlp is None:
            # Attempt to re-initialize if it failed previously
            self._init_nlp()
        if self.nlp is None:
            return {
                "original": word,
                "lemma": word,
                "part_of_speech": None,
                "features": None
            }
        # Use Stanza to process the word (put it into a sentence because the model works on sentences)
        doc = self.nlp(word)
        if not doc.sentences or not doc.sentences[0].words:
            return {
                "original": word,
                "lemma": word,
                "part_of_speech": None,
                "features": None
            }

        result = doc.sentences[0].words[0]

        return {
            "original": word,
            "lemma": result.lemma,
            "part_of_speech": result.upos,
            "features": {
                "xpos": result.xpos,
                "feats": result.feats
            }
        }

