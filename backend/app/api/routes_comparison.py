from fastapi import APIRouter, Depends, HTTPException
from app.services.sentence_comparison_service import SentenceComparisonService
from app.dependencies import get_sentence_comparison_service
from pydantic import BaseModel

router = APIRouter()

class SentenceComparisonRequest(BaseModel):
    sentence1: str
    sentence2: str

@router.post("/compare-sentences")
async def compare_sentences_endpoint(
    request: SentenceComparisonRequest,
    comparison_service: SentenceComparisonService = Depends(get_sentence_comparison_service)
):
    if not request.sentence1 or not request.sentence2:
        raise HTTPException(status_code=400, detail="Both sentences must be provided for comparison.")
    
    try:
        score = comparison_service.compare_sentences(request.sentence1, request.sentence2)
        return {"similarity_score": score}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Sentence comparison failed: {str(e)}")