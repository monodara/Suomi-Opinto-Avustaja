import google.genai as genai
import os
import json

class WritingPracticeService:
    def __init__(self):
        if "GEMINI_API_KEY" not in os.environ:
            print("WARNING: GEMINI_API_KEY environment variable not set.")
            print("Writing practice service might not work without a valid Gemini API key.")
        
        self.client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY"))

    async def correct_and_explain(self, user_paragraph: str, vocabulary_words: list[str]) -> str:
        if not user_paragraph:
            return json.dumps({"error": "No paragraph provided for correction."})
        
        try:
            vocab_list_str = ", ".join(vocabulary_words)
            
            prompt = f"""You are a Finnish language tutor. The user has written a short paragraph in Finnish using some vocabulary words.
            Your task is to:
            1. Correct any grammatical errors, spelling mistakes, or unnatural phrasing in the user's paragraph.
            2. Provide a clear explanation for each correction made.
            3. Comment on how well the provided vocabulary words were used in the context.
            4. Ensure the output is a valid JSON object.

            The output MUST be a JSON object with the following keys:
            - "original_paragraph": (string) The user's original paragraph.
            - "corrected_paragraph": (string) Your corrected version of the paragraph.
            - "corrections_explanation": (string) A detailed explanation of all corrections made.
            - "vocabulary_usage_feedback": (string) Feedback on the usage of the provided vocabulary words.

            User's paragraph: '{user_paragraph}'
            Vocabulary words to consider: {vocab_list_str}
            """
            
            response = await self.client.aio.models.generate_content(
                model="gemini-2.5-flash",
                contents=[prompt],
                config={
                    "response_mime_type": "application/json"
                }
            )
            
            print(f"LLM writing practice response: {response.text}")
            return response.text
        except Exception as e:
            return json.dumps({"error": f"Error during writing practice analysis: {str(e)}"})
