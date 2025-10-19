import stanza
import os
from stanza import DownloadMethod

# Lazily initialized Stanza pipeline
nlp = None

def init_nlp() -> None:
    global nlp
    if nlp is not None:
        return
    
    try:
        # Use REUSE_RESOURCES to avoid re-downloading if model already exists
        nlp = stanza.Pipeline("fi", processors="tokenize,pos,lemma", use_gpu=False, download_method=DownloadMethod.REUSE_RESOURCES)
    except Exception as e:
        # If model is not found despite reuse setting, download it, then create pipeline
        if "not found" in str(e).lower() or "download" in str(e).lower():
            print("Finnish language model not found, downloading...")
            try:
                stanza.download("fi", verbose=False)
                nlp = stanza.Pipeline("fi", processors="tokenize,pos,lemma", use_gpu=False, download_method=DownloadMethod.REUSE_RESOURCES)
                print("Finnish language model downloaded and loaded successfully.")
            except Exception as download_error:
                print(f"Failed to download Finnish language model: {download_error}")
                nlp = None
        else:
            print(f"Error initializing Stanza pipeline: {e}")
            nlp = None

def analyze_finnish_word(word: str):
    if not word:
        return {
            "original": word,
            "lemma": word,
            "part_of_speech": None,
            "features": None
        }
    if nlp is None:
        init_nlp()
    if nlp is None:
        return {
            "original": word,
            "lemma": word,
            "part_of_speech": None,
            "features": None
        }
    # Use Stanza to process the word (put it into a sentence because the model works on sentences)
    doc = nlp(word)
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

