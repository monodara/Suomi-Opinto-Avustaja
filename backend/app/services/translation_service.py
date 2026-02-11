import deepl
import os
import logging

from fastapi import HTTPException

logger = logging.getLogger(__name__)

class TranslationService:
    def __init__(self):
        auth_key = os.getenv("DEEPL_API_KEY")
        if not auth_key:
            logger.warning("DEEPL_API_KEY environment variable not set. Translation service disabled.")
            self.translate_client = None
        else:
            self.translate_client = deepl.DeepLClient(auth_key)

    def translate_text(self, text: str, target_lang: str = 'EN-GB') -> str:
        if not text:
            return ""
        logger.info(f"DeepLClient instance: {self.translate_client}")
        if not self.translate_client:
            raise HTTPException(
                status_code=503,
                detail="Translation service not configured"
            )
        try:
            result = self.translate_client.translate_text(
                text,
                target_lang=target_lang,
            )
            # The DeepL Python library's translate_text method returns a TextResult object, not a dictionary.
            # Access the translated text using the .text attribute.
            return result.text
        except Exception as e:
            logger.error(f"Error during DeepL translation: {e}", exc_info=True)
            raise HTTPException(status_code=500, detail=f"DeepL translation failed: {str(e)}")

