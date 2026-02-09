import asyncio
from playwright.async_api import async_playwright
import logging
from app.config import PAPUNET_IMAGE_SEARCH_URL

logger = logging.getLogger(__name__)

class PapunetScraperService:
    async def scrape_papunet_images(self, word: str):
        """
        Use Playwright to scrape images from the Papunet image library
        :param word: Finnish word to search for
        :return: List of images [{id, url, alt}]
        """
        try:
            async with async_playwright() as p:
                browser = await p.chromium.launch(headless=True)
                page = await browser.new_page()

                search_url = f"{PAPUNET_IMAGE_SEARCH_URL}{word}"
                await page.goto(search_url)
                await page.wait_for_load_state("networkidle")
                await page.wait_for_selector(".Kuvat", timeout=10000)

                images = await page.evaluate('''() => {
                    const container = document.querySelector('.Kuvat');
                    if (!container) return [];

                    const result = [];
                    const links = container.querySelectorAll('a');

                    for (const link of links) {
                        const img = link.querySelector('img');
                        if (img && link.id) {
                            result.push({
                                id: link.id,
                                url: `https://kuha.papunet.net/api/image/${link.id}?lang=fi`,
                                alt: img.alt
                            });
                        }
                    }
                    return result;
                }''')

                await browser.close()
                return images

        except Exception as e:
            logger.error(f"Failed to scrape Papunet images: {e}")
            return []
