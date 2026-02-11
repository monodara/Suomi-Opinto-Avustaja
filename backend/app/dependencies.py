from app.services.news_crawler import NewsCrawlerService
from app.services.papunet_scraper import PapunetScraperService
from app.services.sanakirja_lookup import SanakirjaLookupService
from app.services.tnpp_lookup import TnppLookupService
from app.services.sentence_analysis_service import SentenceAnalysisService
from app.services.translation_service import TranslationService
from app.services.llm_analysis_service import LLMAnalysisService # New import

# Create singleton instances of services
_news_crawler_service = NewsCrawlerService()
_papunet_scraper_service = PapunetScraperService()
_sanakirja_lookup_service = SanakirjaLookupService()
_tnpp_lookup_service = TnppLookupService()
_sentence_analysis_service = SentenceAnalysisService()
_translation_service = TranslationService()
_llm_analysis_service = LLMAnalysisService() # New instance

def get_news_crawler_service() -> NewsCrawlerService:
    return _news_crawler_service

def get_papunet_scraper_service() -> PapunetScraperService:
    return _papunet_scraper_service

def get_sanakirja_lookup_service() -> SanakirjaLookupService:
    return _sanakirja_lookup_service

def get_tnpp_lookup_service() -> TnppLookupService:
    return _tnpp_lookup_service

def get_sentence_analysis_service() -> SentenceAnalysisService:
    return _sentence_analysis_service

def get_translation_service() -> TranslationService:
    return _translation_service

def get_llm_analysis_service() -> LLMAnalysisService: # New dependency getter
    return _llm_analysis_service
