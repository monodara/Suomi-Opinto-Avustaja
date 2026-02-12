from fastapi import APIRouter, Depends, HTTPException
from app.services.writing_practice_service import WritingPracticeService
from app.dependencies import get_writing_practice_service
from pydantic import BaseModel
from typing import List

router = APIRouter()

class WritingPracticeRequest(BaseModel):
    user_paragraph: str
    vocabulary_words: List[str]

@router.post("/writing-practice")
async def writing_practice(
    request: WritingPracticeRequest,
    writing_practice_service: WritingPracticeService = Depends(get_writing_practice_service)
):
    if not request.user_paragraph or not request.user_paragraph.strip():
        raise HTTPException(status_code=400, detail="User paragraph cannot be empty.")
    
    try:
        analysis_result = await writing_practice_service.correct_and_explain(
            request.user_paragraph,
            request.vocabulary_words
        )
        return {"analysis_result": analysis_result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Writing practice analysis failed: {str(e)}")
