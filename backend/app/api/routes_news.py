from fastapi import APIRouter, Depends
from fastapi.responses import JSONResponse
from app.services.news_crawler import NewsCrawlerService
from app.dependencies import get_news_crawler_service

router = APIRouter()
@router.get("/")
async def health_check():
    return {"status": "ok", "message": "News router is working"}

@router.get("/latest-news")
async def latest_news(news_service: NewsCrawlerService = Depends(get_news_crawler_service)):
    try:
        article = await news_service.get_latest_article()
        if article is None:
            return JSONResponse(
                content={"error": "No article found"}, 
                status_code=404
            )
        return JSONResponse(content=article, media_type="application/json; charset=utf-8")
    except Exception as e:
        return JSONResponse(
            content={"error": f"Internal server error: {str(e)}"}, 
            status_code=500
        )
