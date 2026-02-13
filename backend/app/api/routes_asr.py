from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from app.services.asr_service import ASRService
from app.dependencies import get_asr_service
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/asr")
async def transcribe_audio_endpoint(
    audio_file: UploadFile = File(...),
    asr_service: ASRService = Depends(get_asr_service)
):
    if not audio_file:
        raise HTTPException(status_code=400, detail="No audio file provided.")
    
    try:
        audio_data = await audio_file.read()
        transcribed_text = await asr_service.transcribe_audio(audio_data)
        return {"transcribed_text": transcribed_text}
    except Exception as e:
        logger.error(f"Error during ASR transcription: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"ASR transcription failed: {str(e)}")
