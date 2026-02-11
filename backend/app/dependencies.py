from app.services.news_crawler import NewsCrawlerService
from app.services.papunet_scraper import PapunetScraperService
from app.services.sanakirja_lookup import SanakirjaLookupService
from app.services.tnpp_lookup import TnppLookupService
from app.services.sentence_analysis_service import SentenceAnalysisService # New import

# Create singleton instances of services
_news_crawler_service = NewsCrawlerService()
_papunet_scraper_service = PapunetScraperService()
_sanakirja_lookup_service = SanakirjaLookupService()
_tnpp_lookup_service = TnppLookupService()
_sentence_analysis_service = SentenceAnalysisService() # New instance

def get_news_crawler_service() -> NewsCrawlerService:
    return _news_crawler_service

def get_papunet_scraper_service() -> PapunetScraperService:
    return _papunet_scraper_service

def get_sanakirja_lookup_service() -> SanakirjaLookupService:
    return _sanakirja_lookup_service

def get_tnpp_lookup_service() -> TnppLookupService:
    return _tnpp_lookup_service

def get_sentence_analysis_service() -> SentenceAnalysisService: # New dependency getter
    return _sentence_analysis_service
