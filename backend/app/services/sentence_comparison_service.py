import Levenshtein
import time # Import time module
import logging # Import logging module

logger = logging.getLogger(__name__) # Initialize logger

class SentenceComparisonService:
    def compare_sentences(self, sentence1: str, sentence2: str) -> float:
        start_time = time.time()
        logger.info("Comparison: Starting sentence comparison.")

        s1_normalized = self._normalize_text(sentence1)
        s2_normalized = self._normalize_text(sentence2)

        if not s1_normalized and not s2_normalized:
            logger.info(f"Comparison: Finished sentence comparison in {time.time() - start_time:.2f} seconds (both empty).")
            return 1.0
        if not s1_normalized or not s2_normalized:
            logger.info(f"Comparison: Finished sentence comparison in {time.time() - start_time:.2f} seconds (one empty).")
            return 0.0

        distance = Levenshtein.distance(s1_normalized, s2_normalized)
        
        max_len = max(len(s1_normalized), len(s2_normalized))
        
        if max_len == 0:
            logger.info(f"Comparison: Finished sentence comparison in {time.time() - start_time:.2f} seconds (max_len 0).")
            return 1.0
            
        similarity = 1.0 - (distance / max_len)
        end_time = time.time()
        logger.info(f"Comparison: Finished sentence comparison in {end_time - start_time:.2f} seconds. Similarity: {similarity:.2f}")
        return max(0.0, min(1.0, similarity))

    def _normalize_text(self, text: str) -> str:
        text = text.lower()
        text = ''.join(char for char in text if char.isalnum() or char.isspace())
        text = ' '.join(text.split())
        return text
