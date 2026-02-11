from google import genai
import os
import json # Import json for potential parsing/validation

class LLMAnalysisService:
    def __init__(self):
        if "GEMINI_API_KEY" not in os.environ:
            print("WARNING: GEMINI_API_KEY environment variable not set.")
            print("LLM analysis service might not work without a valid Gemini API key.")
        
        self.client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY"))

    async def analyze_text(self, text: str) -> str:
        if not text:
            return "No text provided for analysis."
        
        try:
            # Refined prompt to explicitly request JSON output
            prompt = f"""Analyze the following Finnish sentence and provide its grammatical structure and cultural nuances.
            The output MUST be a JSON object with the following keys:
            - "grammatical_structure": (string) A concise, human-readable summary of the sentence's grammatical components, focusing on key elements like subject, verb, objects, and their roles.
            - "cultural_nuances": (string) Any cultural context or implications of the sentence.

            Finnish Sentence: '{text}'
            """
            
            # Use generate_content with response_mime_type for JSON output
            response = await self.client.aio.models.generate_content(
                model="gemini-2.5-flash",
                contents=[prompt],
                config={
                "response_mime_type": "application/json",
            }
            )
            
            # The response.text should now be a JSON string
            print(f"LLM analysis response: {response.text}")
            return response.text
        except Exception as e:
            return f"Error during LLM analysis: {str(e)}"


