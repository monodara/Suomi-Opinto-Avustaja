from fastapi import APIRouter, Depends, HTTPException
from app.services.llm_analysis_service import LLMAnalysisService
from app.dependencies import get_llm_analysis_service
from pydantic import BaseModel

router = APIRouter()

class TextRequest(BaseModel):
    text: str

@router.post("/llm-analyze")
async def llm_analyze_text(
    request: TextRequest,
    llm_analysis_service: LLMAnalysisService = Depends(get_llm_analysis_service)
):
    if not request.text or not request.text.strip():
        raise HTTPException(status_code=400, detail="Text parameter cannot be empty.")
    
    try:
        analysis_result = await llm_analysis_service.analyze_text(request.text)
        return {"analysis_result": analysis_result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"LLM analysis failed: {str(e)}")
