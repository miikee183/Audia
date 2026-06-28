# Audia

Audia is a social audio platform that lets you record and share short voice clips (up to 60 seconds) with your friends and followers. Think of it as a voice-based social network — record, publish, like, and comment on audio posts.

## Features

- **Audio Recording** — Hold-to-record with swipe-to-lock, playback controls, and speed adjustment
- **Feed** — Browse audio from everyone, your contacts, or only people you follow
- **Social** — Follow/unfollow users, like and comment on audio posts
- **Private Accounts** — Make your profile private so only mutual followers can hear your audios
- **Block Users** — Block accounts to prevent them from interacting with your content
- **Localization** — Full app translated into 11 languages (English, Spanish, French, Portuguese, German, Italian, Russian, Arabic, Chinese, Korean, Japanese)
- **Dark & Light Theme** — Toggle between dark and light mode, persisted across sessions
- **Inbox** — View notifications for likes, comments, and new followers
- **Profile** — Customize your photo, username, and bio; view your audio history

## Screenshots

| | | |
|:---:|:---:|:---:|
| ![1](imagenes/readme1.png) | ![2](imagenes/readme2.png) | ![3](imagenes/readme3.png) |
| ![4](imagenes/readme4.png) | ![5](imagenes/readme5.png) | ![6](imagenes/readme6.png) |
| ![7](imagenes/readme7.png) | | |

## Tech Stack

- **Frontend:** Flutter / Dart
- **Backend:** Python / FastAPI
- **Database:** PostgreSQL (SQLAlchemy ORM)
- **Authentication:** Google Sign-In (Firebase Auth)
- **Media Storage:** Cloudinary
- **Deployment:** Render (backend), Google Play (frontend — upcoming)

## Getting Started

### Prerequisites

- Flutter SDK
- Python 3.11+
- PostgreSQL

### Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### Frontend

```bash
cd audia_app
flutter pub get
flutter run
```

## License

All rights reserved.
