# SisuHyy - Finnish Learning App

![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![DeepL](https://img.shields.io/badge/DeepL-2C80FF?style=for-the-badge&logo=deepl&logoColor=white)
![SpeechRecognition](https://img.shields.io/badge/SpeechRecognition-4285F4?style=for-the-badge&logo=google&logoColor=white)
![spaCy](https://img.shields.io/badge/spaCy-09A3D5?style=for-the-badge&logo=spacy&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-E05D44?style=for-the-badge&logo=hive&logoColor=white)
![python-Levenshtein](https://img.shields.io/badge/Levenshtein-4285F4?style=for-the-badge&logo=python&logoColor=white)
![Playwright](https://img.shields.io/badge/Playwright-2EAD33?style=for-the-badge&logo=playwright&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini-4285F4?style=for-the-badge&logo=google&logoColor=white)

SisuHyy is an AI-powered Finnish language learning application designed to help users effectively improve their Finnish proficiency. It combines news reading, vocabulary management, and interactive practice modules, leveraging advanced AI and NLP techniques for deep linguistic analysis, intelligent feedback, and engaging learning experiences.

Moving beyond traditional translation, SisuHyy focuses on fostering natural language acquisition through features like AI-driven word definitions, contextual translation, AI-powered writing feedback, and interactive shadowing practice.

## Features

- **News Reading**: Fetches and displays news articles from Yle uutiset and Yle selkouutiset.
- **AI-Powered Word Definitions**: Provides detailed definitions, AI-driven grammar analysis (morphological tagging, lemmatization), and compound word breakdowns.
- **Vocabulary Management**: Save and organize words in your personal word bank.
- **Flashcard Learning**: Spaced repetition flashcards for effective vocabulary retention.
- **AI Image Generation**: Visual representation of words to enhance learning through AI-generated images.
- **Offline Reading**: Local storage of articles for offline access.
- **Intelligent Sentence Analysis**: Double-click words in articles to get AI-powered grammatical structure and cultural nuances.
- **Contextual Translation**: Translate sentences using the DeepL API.
- **AI-Powered Writing Practice**: Get AI-driven corrections and feedback on Finnish paragraphs.
- **Interactive Shadowing Practice**: Practice pronunciation with TTS audio, Automatic Speech Recognition (ASR), and similarity scoring.

## Project Structure

```
hyva-suomi/
├── backend/          # Python FastAPI backend
│   ├── app/
│   │   ├── api/      # API routes
│   │   ├── models/   # Data models
│   │   ├── services/ # Business logic
│   │   └── main.py   # Application entry point
│   └── requirements.txt
└── frontend/         # Flutter mobile application
    ├── lib/
    │   ├── models/    # Data models
    │   ├── pages/     # UI screens
    │   ├── utils/     # Utility functions
    │   └── widgets/   # Custom widgets
    ├── pubspec.yaml
    └── ...
```

## Backend (Python FastAPI)

The backend provides robust APIs for:
- **News Processing**: Crawling and processing news articles from various sources.
- **Word Analysis**: Detailed word definition, morphological tagging, lemmatization, and grammar analysis using TNPP and suomisanakirja.fi.
- **Visual Learning**: Fetching AI-generated images from Papunet to enhance vocabulary retention.
- **Sentence Segmentation**: Utilizing spaCy for accurate sentence splitting.
- **Translation**: Seamless integration with DeepL API for sentence translation.
- **AI Analysis**: Leveraging Gemini API for in-depth grammatical structure and cultural nuance analysis of Finnish sentences.
- **Writing Practice**: Providing AI-powered corrections and explanations for user-submitted Finnish paragraphs.
- **Speech Recognition (ASR)**: Transcribing spoken Finnish audio to text using Google Web Speech API.
- **Sentence Comparison**: Calculating similarity scores between two sentences using Levenshtein distance.
- **External Service Integration**: Connecting with various external services like suomisanakirja.fi.

## Frontend (Flutter)

The frontend is a dynamic and interactive Flutter application with:
- **News Browsing**: Seamlessly browse and read news articles.
- **Interactive Word Definitions**: Tap on words to get instant definitions, grammar analysis, and examples.
- **Vocabulary Management**: A personal word bank to save and organize learned words.
- **Flashcard System**: Spaced repetition flashcards for effective vocabulary memorization.
- **Offline Access**: Local data storage with Hive for offline reading and learning.
- **Shadowing Practice**: An immersive feature for pronunciation practice, offering TTS playback, voice recording, ASR transcription, and similarity scoring against original sentences.
- **Writing Practice Interface**: A dedicated section for users to practice writing Finnish, receiving AI-driven feedback.
- **Intuitive Navigation**: Easy navigation between different learning modules.

## Setup Instructions

### Backend Setup
1. Navigate to the backend directory:
   ```
   cd backend
   ```
2. Create a virtual environment:
   ```
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies:
   ```
   pip install -r requirements.txt
   ```
4. Download Stanza Finnish model:
   ```
   python -c "import stanza; stanza.download('fi')"
   ```
5. Install Playwright browsers (for Papunet scraper):
   ```
   playwright install
   ```
6. Set up environment variables:
   *   **DeepL API Key (for translation)**: Set `DEEPL_API_KEY=YOUR_DEEPL_API_KEY`.
   *   **Gemini API Key (for LLM analysis and writing practice)**: Set `GEMINI_API_KEY=YOUR_GEMINI_API_KEY`.
   *   **(Optional) Google Cloud Translation API**: If using Google Cloud Translation instead of DeepL, set `GOOGLE_APPLICATION_CREDENTIALS=/path/to/your/service_account_key.json`.
7. Start the backend server:
   ```
   uvicorn app.main:app --reload --port 8090
   ```

### Frontend Setup
1. Navigate to the frontend directory:
   ```
   cd frontend
   ```
2. Install Flutter dependencies:
   ```
   flutter pub get
   ```
3. Run the application:
   ```
   flutter run
   ```

## API Endpoints

- `GET /latest-news` - Fetch latest news articles
- `GET /define?word=<word>` - Get word definitions
- `GET /papunet-images/{word}` - Get images for a word from Papunet
- `POST /segment-sentences` - Segment a given text into sentences using spaCy.
- `POST /translate` - Translate a given text using DeepL API.
- `POST /llm-analyze` - Analyze a given text using Gemini API for grammatical structure and cultural nuances.
- `POST /writing-practice` - Get AI-powered corrections and feedback on a user's Finnish paragraph.
- `POST /asr` - Transcribe audio data to text using Google Web Speech API.
- `POST /compare-sentences` - Compare two sentences and return a similarity score.

