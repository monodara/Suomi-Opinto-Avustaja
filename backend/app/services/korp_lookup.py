import requests

def get_lemma_from_korp(word: str):
    url = "https://korp.csc.fi/korp/cgi-bin/korp.cgi"
    params = {
        "command": "query",
        "corpus": "YLE_NEWS",
        "cqp": f'"{word}"',
        "show": "word,lemma,msd,pos",
        "start": 0,
        "end": 1
    }
    resp = requests.get(url, params=params)
    data = resp.json()
    try:
        kwic = data["kwic"][0]
        tokens = kwic["tokens"]
        for t in tokens:
            if t.get("word", "").lower() == word.lower():
                return t.get("lemma", word)
    except Exception:
        pass
    return word
