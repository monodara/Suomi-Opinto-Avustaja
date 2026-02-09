from app.services.news_crawler import NewsCrawlerService
from app.services.papunet_scraper import PapunetScraperService
from app.services.sanakirja_lookup import SanakirjaLookupService
from app.services.tnpp_lookup import TnppLookupService

# Create singleton instances of services
_news_crawler_service = NewsCrawlerService()
_papunet_scraper_service = PapunetScraperService()
_sanakirja_lookup_service = SanakirjaLookupService()
_tnpp_lookup_service = TnppLookupService()

def get_news_crawler_service() -> NewsCrawlerService:
    return _news_crawler_service

def get_papunet_scraper_service() -> PapunetScraperService:
    return _papunet_scraper_service

def get_sanakirja_lookup_service() -> SanakirjaLookupService:
    return _sanakirja_lookup_service

def get_tnpp_lookup_service() -> TnppLookupService:
    return _tnpp_lookup_service
