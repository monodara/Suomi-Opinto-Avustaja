from fastapi import APIRouter
from fastapi.responses import JSONResponse
from app.services.news_crawler import get_latest_article

router = APIRouter()
@router.get("/")
async def health_check():
    return {"status": "ok", "message": "News router is working"}

@router.get("/latest-news")
async def latest_news():
    try:
        article = await get_latest_article()
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
