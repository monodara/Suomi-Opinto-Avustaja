import libvoikko
import re

voikko = libvoikko.Voikko("fi")

def analyze_finnish_word(word: str):
    analysis = voikko.analyze(word)
    if not analysis:
        return {
            "original": word,
            "lemma": word,
            "part_of_speech": None,
            "features": None
        }

    result = analysis[0]

    # try to extract lemma from WORDBASES
    lemma = result.get("BASEFORM", word)  
    wordbases = result.get("WORDBASES")
    if wordbases:
        match = re.search(r'\((.*?)\)', wordbases)
        if match:
            lemma = match.group(1)

    return {
        "original": word,
        "lemma": lemma,
        "part_of_speech": result.get("CLASS"),
        "features": result.get("MORPHOLOGY")
    }
