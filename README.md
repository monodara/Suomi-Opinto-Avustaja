# SisuHyy - Finnish Learning App

![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Cursor](https://img.shields.io/badge/Cursor-4B4B4B?style=for-the-badge&logo=cursor&logoColor=white)
![Gemini](https://img.shields.io/badge/Gemini-4285F4?style=for-the-badge&logo=google&logoColor=white)
![PyTorch](https://img.shields.io/badge/PyTorch-%23EE4C2C.svg?style=for-the-badge&logo=PyTorch&logoColor=white)
![Stable%20Diffusion](https://img.shields.io/badge/Stable%20Diffusion-000000?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyQzYuNDggMiAyIDYuNDggMiAxMnM0LjQ4IDEwIDEwIDEwIDEwLTQuNDggMTAtMTBTMTcuNTIgMiAxMiAyem0zLjY4IDExLjg0TDEyIDEwLjEyIDguMzIgMTMuOCA3IDExLjY4IDEyIDQuMTYgMTcgMTEuNjggMTUuNjggMTMuODR6Ii8+PC9zdmc+)

SisuHyy is a comprehensive Finnish language learning application that provides news reading, vocabulary management, and flashcard-based learning to help users improve their Finnish language skills.

## Features

- **News Reading**: Fetches and displays news articles from Yle uutiset and Yle selkouutiset
- **Word Definitions**: Provides detailed definitions, grammar analysis, and compound word breakdowns
- **Vocabulary Management**: Save and organize words in your personal word bank
- **Flashcard Learning**: Spaced repetition flashcards for effective vocabulary retention
- **AI Image Generation**: Visual representation of words to enhance learning
- **Offline Reading**: Local storage of articles for offline access

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

The backend provides APIs for:
- News crawling and processing
- Word definition and grammar analysis
- Image fetching from Papunet
- Integration with external services (suomisanakirja.fi, etc.)

### Dependencies
- FastAPI
- BeautifulSoup4
- Playwright (for web scraping)
- Stanza (Finnish NLP)
- PyVoikko
- Requests
- HTTPX

## Frontend (Flutter)

The frontend is a Flutter application with:
- News browsing and reading
- Interactive word definitions
- Vocabulary management
- Flashcard system
- Local data storage with Hive

### Dependencies
- http
- html
- hive & hive_flutter
- path_provider
- url_launcher
- cupertino_icons

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
4. Start the backend server:
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

