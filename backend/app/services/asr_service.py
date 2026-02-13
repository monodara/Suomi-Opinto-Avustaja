import speech_recognition as sr
import io
import wave

class ASRService:
    def __init__(self):
        self.recognizer = sr.Recognizer()

    async def transcribe_audio(self, audio_data: bytes, language: str = "fi-FI") -> str:
        # SpeechRecognition expects audio data in a specific format.
        # Assuming audio_data is raw bytes, we need to convert it to a format
        # that can be processed by the recognizer.
        # A common format for Flutter audio recorders is WAV.
        # This example assumes the input audio_data is already in WAV format.
        # If not, additional conversion steps would be needed.

        try:
            # Create a BytesIO object from the audio data
            audio_file = io.BytesIO(audio_data)
            
            # Use SpeechRecognition's AudioFile context manager
            with sr.AudioFile(audio_file) as source:
                audio = self.recognizer.record(source) # read the entire audio file
            
            # Transcribe using Google Web Speech API
            text = self.recognizer.recognize_google(audio, language=language)
            return text
        except sr.UnknownValueError:
            return "Could not understand audio"
        except sr.RequestError as e:
            return f"Could not request results from Google Web Speech API service; {e}"
        except Exception as e:
            return f"Error during audio transcription: {e}"
