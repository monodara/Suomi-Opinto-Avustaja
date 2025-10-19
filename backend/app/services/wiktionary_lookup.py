import requests

def get_definition_from_wiktionary(word: str):
    url = "https://fi.wiktionary.org/w/api.php"
    params = {
        "action": "query",
        "format": "json",
        "prop": "extracts",
        "titles": word,
        "explaintext": True,
        "redirects": 1,
    }

    try:
        resp = requests.get(url, params=params)
        data = resp.json()
        pages = data["query"]["pages"]
        page = next(iter(pages.values()))

        if "extract" in page:
            raw = page["extract"]
            lines = raw.split("\n")
            clean_lines = [line for line in lines if line.strip() and not line.startswith("===")]
            return "\n".join(clean_lines[:5])
    except Exception:
        pass
    return None
