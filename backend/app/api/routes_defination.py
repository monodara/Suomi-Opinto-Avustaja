from fastapi import APIRouter, HTTPException
from fastapi.responses import JSONResponse
from ..services.tnpp_lookup import analyze_finnish_word
from ..services.sanakirja_lookup import fetch_sanakirja_definitions

router = APIRouter()

@router.get("/define")
async def define_word(word: str):
    if not word or not word.strip():
        raise HTTPException(status_code=400, detail="Word parameter cannot be empty.")
    # use TNPP model to analyze word form and lemma
    tnpp_result = analyze_finnish_word(word)
    lemma_str = tnpp_result["lemma"]  # it can be like 'alennus#myynti'
    feats = tnpp_result.get("features", "")

    # split each part in lemma
    lemmas = lemma_str.split("#") if lemma_str else []

    # look up each lemma's definition in suomisanakirja
    parts = []
    for lemma in lemmas:
        if lemma:
            sanakirja_data = await fetch_sanakirja_definitions(lemma)
            parts.append({
                "word": lemma,
                "pos": sanakirja_data.get("pos"),
                "meanings": sanakirja_data.get("meanings", [])
            })
    return JSONResponse(
        content={
            "word": word,
            "parts": parts,
            "feats": feats
        },
        media_type="application/json; charset=utf-8"
    )
