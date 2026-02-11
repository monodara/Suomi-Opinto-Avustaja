from fastapi import APIRouter, Depends, HTTPException
from app.services.translation_service import TranslationService
from app.dependencies import get_translation_service
from pydantic import BaseModel

router = APIRouter()

class TranslationRequest(BaseModel):
    text: str
    target_language: str = 'EN-GB'
    source_language: str = 'fi'

@router.post("/translate")
async def translate_text(
    request: TranslationRequest,
    translation_service: TranslationService = Depends(get_translation_service)
):
    if not request.text or not request.text.strip():
        raise HTTPException(status_code=400, detail="Text parameter cannot be empty.")
    
    try:
        translated_text = translation_service.translate_text(
            request.text,
            target_lang=request.target_language,
            # source_lang=request.source_language
        )
        return {"translated_text": translated_text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Translation failed: {str(e)}")
