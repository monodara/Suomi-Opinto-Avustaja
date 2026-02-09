from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import JSONResponse
from app.services.tnpp_lookup import TnppLookupService
from app.services.sanakirja_lookup import SanakirjaLookupService
from app.dependencies import get_tnpp_lookup_service, get_sanakirja_lookup_service

router = APIRouter()

@router.get("/define")
async def define_word(
    word: str,
    tnpp_service: TnppLookupService = Depends(get_tnpp_lookup_service),
    sanakirja_service: SanakirjaLookupService = Depends(get_sanakirja_lookup_service)
):
    if not word or not word.strip():
        raise HTTPException(status_code=400, detail="Word parameter cannot be empty.")
    # use TNPP model to analyze word form and lemma
    tnpp_result = tnpp_service.analyze_finnish_word(word)
    lemma_str = tnpp_result["lemma"]  # it can be like 'alennus#myynti'
    feats = tnpp_result.get("features", "")

    # split each part in lemma
    lemmas = lemma_str.split("#") if lemma_str else []

    # look up each lemma's definition in suomisanakirja
    parts = []
    for lemma in lemmas:
        if lemma:
            sanakirja_data = await sanakirja_service.fetch_sanakirja_definitions(lemma)
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
