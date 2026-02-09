import httpx
from bs4 import BeautifulSoup
import random
import asyncio
import logging
from app.config import SUOMISANAKIRJA_BASE_URL

logger = logging.getLogger(__name__)

class SanakirjaLookupService:
    async def fetch_sanakirja_definitions(self, word: str):
        url = f"{SUOMISANAKIRJA_BASE_URL}{word}"
        
        headers = {
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
            "Accept-Language": "fi-FI,fi;q=0.9,en-US;q=0.8,en;q=0.7",
            # Remove Accept-Encoding or only keep gzip, deflate
            "Accept-Encoding": "gzip, deflate",
        }
        
        await asyncio.sleep(random.uniform(1, 3))
        
        try:
            async with httpx.AsyncClient(
                timeout=30.0,
                headers=headers,
                follow_redirects=True
            ) as client:
                response = await client.get(url)
                
                if response.status_code != 200:
                    logger.error(f"Failed to fetch page for word: {word}, status code: {response.status_code}")
                    return {
                        "word": word,
                        "pos": None,
                        "meanings": [],
                        "error": f"HTTP {response.status_code}"
                    }
            
            logger.info(f"Content-Encoding: {response.headers.get('content-encoding')}")
            
            # httpx should automatically handle gzip/deflate, manually handle if receive br
            if response.headers.get('content-encoding') == 'br':
                logger.info("Content encoded with Brotli, attempting decompression...")
                try:
                    # Manual Brotli decompression if needed
                    import brotli
                    html_content = brotli.decompress(response.content).decode('utf-8')
                    logger.info("✓ Successfully decompressed Brotli content")
                except Exception as e:
                    logger.error(f"Brotli decompression failed: {e}")
                    # If Brotli decompression fails, try direct decoding (might cause garbled text)
                    html_content = response.text
                # Continue with the original parsing logic...
            else:
                # httpx will automatically handle other compressions
                html_content = response.text
            
            # Continue with the original parsing logic...
            soup = BeautifulSoup(html_content, "html.parser")

            # Add more robust selector
            container = soup.find("div", id="container")
            if not container:
                return {
                    "word": word,
                    "pos": None,
                    "meanings": [],
                }

            # Find all h4 tags (there may be multiple parts of speech)
            h4_tags = container.find_all("h4")
            if not h4_tags:
                return {
                    "word": word,
                    "pos": None,
                    "meanings": [],
                }

            # Process the first part of speech definition
            first_h4 = h4_tags[0]
            
            # Find the corresponding definition list
            next_tag = first_h4.find_next_sibling()
            while next_tag and next_tag.name != "ol":
                next_tag = next_tag.find_next_sibling()
                
            if not next_tag:
                return {
                    "word": word,
                    "pos": first_h4.text.strip(),
                    "meanings": [],
                }

            pos = first_h4.text.strip()
            
            meanings = []
            for li in next_tag.find_all("li"):
                # More robust text extraction
                definition_elem = li.find("p")
                example_elem = li.find("em")
                
                definition = definition_elem.get_text(strip=True) if definition_elem else ""
                example = example_elem.get_text(strip=True) if example_elem else ""
                
                # Only add definitions with content
                if definition:
                    meanings.append({
                        "definition": definition,
                        "example": example
                    })

            
            return {
                "word": word,
                "pos": pos,
                "meanings": meanings
            }
            
        except httpx.RequestError as e:
            logger.error(f"Network error for word {word}: {e}")
            return {
                "word": word,
                "pos": None,
                "meanings": [],
                "error": f"Network error: {str(e)}"
            }
        except Exception as e:
            logger.error(f"Unexpected error for word {word}: {e}")
            return {
                "word": word,
                "pos": None,
                "meanings": [],
                "error": f"Processing error: {str(e)}"
            }