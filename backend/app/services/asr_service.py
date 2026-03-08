import speech_recognition as sr
import io
import wave
import time # Import time module
import logging # Import logging module

logger = logging.getLogger(__name__) # Initialize logger

class ASRService:
    def __init__(self):
        self.recognizer = sr.Recognizer()

    async def transcribe_audio(self, audio_data: bytes, language: str = "fi-FI") -> str:
        start_time = time.time()
        logger.info("ASR: Starting audio transcription.")

        try:
            audio_file = io.BytesIO(audio_data)
            
            with sr.AudioFile(audio_file) as source:
                audio = self.recognizer.record(source)
            
            text = self.recognizer.recognize_google(audio, language=language)
            end_time = time.time()
            logger.info(f"ASR: Finished audio transcription in {end_time - start_time:.2f} seconds.")
            return text
        except sr.UnknownValueError:
            logger.warning("ASR: Could not understand audio.")
            return "Could not understand audio"
        except sr.RequestError as e:
            logger.error(f"ASR: Could not request results from Google Web Speech API service; {e}")
            return f"Could not request results from Google Web Speech API service; {e}"
        except Exception as e:
            logger.error(f"ASR: Error during audio transcription: {e}")
            return f"Error during audio transcription: {e}"
