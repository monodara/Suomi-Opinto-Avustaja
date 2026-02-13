import Levenshtein

class SentenceComparisonService:
    def compare_sentences(self, sentence1: str, sentence2: str) -> float:
        # Normalize sentences (lowercase, remove punctuation) for better comparison
        s1_normalized = self._normalize_text(sentence1)
        s2_normalized = self._normalize_text(sentence2)

        if not s1_normalized and not s2_normalized:
            return 1.0 # Both empty, considered 100% similar
        if not s1_normalized or not s2_normalized:
            return 0.0 # One empty, one not, considered 0% similar

        # Calculate Levenshtein distance
        distance = Levenshtein.distance(s1_normalized, s2_normalized)
        
        # Calculate similarity score (0.0 to 1.0)
        # Max length is used to normalize the distance
        max_len = max(len(s1_normalized), len(s2_normalized))
        
        if max_len == 0: # Should not happen if both are not empty, but as a safeguard
            return 1.0
            
        similarity = 1.0 - (distance / max_len)
        return max(0.0, min(1.0, similarity)) # Ensure score is between 0 and 1

    def _normalize_text(self, text: str) -> str:
        # Convert to lowercase
        text = text.lower()
        # Remove punctuation (keeping spaces)
        text = ''.join(char for char in text if char.isalnum() or char.isspace())
        # Remove extra spaces
        text = ' '.join(text.split())
        return text
