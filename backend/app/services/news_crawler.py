import json
import time
from typing import Optional
import logging

import httpx
from bs4 import BeautifulSoup
from app.config import YLE_SEKOUUTISET_URL, NEWS_CACHE_TTL_SECONDS

logger = logging.getLogger(__name__)

class NewsCrawlerService:
    def __init__(self):
        self._cache_article: Optional[dict] = None
        self._cache_ts: float = 0.0

    async def get_latest_article(self):
        now = time.time()
        if self._cache_article is not None and (now - self._cache_ts) < NEWS_CACHE_TTL_SECONDS:
            return self._cache_article

        url = YLE_SEKOUUTISET_URL
        headers = {"User-Agent": "Mozilla/5.0"}
        async with httpx.AsyncClient(timeout=10) as client:
            response = await client.get(url, headers=headers)
            response.raise_for_status()
            html = response.text
        soup = BeautifulSoup(html, 'html.parser')

        content_root = soup.select_one("div#yle__contentAnchor")
        if not content_root:
            return None

        # extract date and main title from header
        header = content_root.select_one("header") if content_root else None
        # only take the date info "tiistai 5.8.2025"
        raw_date = header.select_one("h1").get_text(strip=True) if header and header.select_one("h1") else ""
        date_text = raw_date.split("|")[-1].strip()
        main_title = header.select_one("p").get_text(strip=True) if header and header.select_one("p") else ""
        # crawl the figure
        figure = header.select_one("figure") if header else None
        image_url = None
        caption = None
        if figure:
            script_tag = figure.find("script", {"type": "application/ld+json"})
            if script_tag:
                try:
                    data = json.loads(script_tag.string)
                    video = data.get("video", {})
                    image_url = video.get("thumbnailUrl")
                    caption = video.get("name")
                except Exception as e:
                    logger.error(f"Failed to parse JSON-LD: {e}")

        # extract news article content
        section = content_root.select_one("section.yle__article__content") if content_root else None
        content_blocks = []
        for elem in (section.find_all(["h2", "p"]) if section else []):
            tag_type = elem.name
            text = elem.get_text(strip=True)
            if text:
                content_blocks.append({
                    "type": tag_type,
                    "text": text
                })

        article = {
            "date": date_text,
            "title": main_title,
            "image": {
                "url": image_url,
                "caption": caption
            },
            "content": content_blocks,
        }

        self._cache_article = article
        self._cache_ts = now
        return article


