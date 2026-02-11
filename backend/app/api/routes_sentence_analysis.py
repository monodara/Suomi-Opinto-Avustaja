from fastapi import APIRouter, Depends, HTTPException
from app.services.sentence_analysis_service import SentenceAnalysisService
from app.dependencies import get_sentence_analysis_service
from pydantic import BaseModel

router = APIRouter()

class TextRequest(BaseModel):
    text: str

@router.post("/segment-sentences")
async def segment_sentences(
    request: TextRequest,
    sentence_analysis_service: SentenceAnalysisService = Depends(get_sentence_analysis_service)
):
    if not request.text or not request.text.strip():
        raise HTTPException(status_code=400, detail="Text parameter cannot be empty.")
    
    sentences = sentence_analysis_service.segment_sentences(request.text)
    return {"sentences": sentences}
