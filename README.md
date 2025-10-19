<!-- 🌌 HackTX 스타일 배너 -->
<p align="center">
  <img src="https://github.com/wjy0524/HackTX25-DYSCVER/blob/main/frontend/assets/images/banner.png" 
       alt="Dystrace Hero Banner" 
       width="100%" 
       style="border-radius:10px;"/>
</p>

# Dystrace: Dyslexia Data Collection Platform

<img width="1144" height="760" alt="image" src="https://github.com/user-attachments/assets/455e2e3c-66b7-4144-9605-c7b2070173b8" />
Dystrace is a web-based platform designed to collect and analyze multimodal data — including reading accuracy, speech patterns, comprehension scores, and real-time gaze tracking — to support dyslexia research and clinical diagnosis.

Dyslexia varies widely in type and severity, making it difficult to diagnose with simple tests. Dystrace enables experts to make more reliable assessments by collecting diverse signals such as users’ reading accuracy, vocal output, comprehension, and eye movement data.

When a user logs in, they enter demographic information (e.g., age, gender, education level) and read a text passage appropriate for their age group. Their reading is recorded through the microphone, and reading accuracy is evaluated by comparing it to the reference text using Levenshtein similarity. The platform also tracks eye movements and evaluates comprehension through automatically generated questions.

While Dystrace does not directly diagnose dyslexia, it builds a comprehensive dataset from multiple behavioral indicators, enabling researchers and clinicians to make better-informed analyses.


# 🚀 Key Features
- **Reading Test**  
  - Presents reading passages matched to user's age
  - Records speech and gaze data in real time
  - Measures reading accuracy (Levenshtein), speed (WPM), fixation/regression count, and cognitive load

- **Comprehension Test**  
  - Automatically generates multiple-choice questions using GPT-4o-Mini
  - Calculates and records comprehension scores

- **Clinic Locator**  
  - Interactive map powered by OpenStreetMap and Flutter Map 
  - Lists major dyslexia support centers and web resources

- **User Profile & History**  
  - User authentication with Firebase Auth 
  - Test results stored in Cloud Firestore 
  - Displays past records and statistical comparisons


# 📦 Tech Stack

- **Frontend**  
  - Flutter Web  
  - `flutter_map`, OpenStreetMap  
  - `firebase_auth`, `cloud_firestore`  
  - `flutter_widget_from_html_core` (리치 텍스트)

- **Backend**  
  - FastAPI + Uvicorn  
  - Whisper for STT and WAV conversion (`ffmpeg`)  
  - Levenshtein similarity calculation
  - GPT-4o-Mini for passage and question generation
  - CORS middleware for cross-origin access

- **Machine Learning (Research)**  
  - Random Forest model for dyslexia risk prediction (joblib)

 
# 🛠️ Setup Guide

## 1. Backend Server

### Virtual Environment & Dependencies
```                   
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```                        

### Add OpenAI API Key into .env file
* echo "OPENAI_API_KEY=sk-…" > .env

### Add Firebase Admin Key into .config_secret folder
* Place serviceAccountKey.json in the .config_secret folder

Firebase Admin key(JSON) is located in backend/.config_secret/serviceAccountKey.json 
```bash  
{
   "type": "...",
   "project_id": "...",
   "private_key_id": "...",
   "private_key": "...”,
   "client_email": "...",
   "client_id": "...",
   "auth_uri": "...”,
   "token_uri": "...",
   "auth_provider_x509_cert_url": "...",
   "client_x509_cert_url": "...",
   "universe_domain": "..."
 }
```

### Run Backend
```
cd backend
uvicorn main:app —-reload
```

## 2. Frontend Server

### Run Frontend
```
cd frontend
flutter clean
flutter pub get
flutter run -d chrome
```
## 3. ml_pipeline Server

### Run ml_pipeline 
```
cd ml_pipeline
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```
### Train the Dyslexia Model
* After installing dependencies, train and export the Random Forest model:
  python train_and_save.py


# 📸 Main Screens

to be updated



# 👥 Developers


| Name | Photo | Role | Affiliation | GitHub |
|------|------|------|-----------|--------|
| **Jaeyeon Won** | ![IMG_4743](https://github.com/user-attachments/assets/f4e5ddbd-1e0b-46dc-9bd4-1e5b5702e933) | Backend · WebGazer · ML Pipeline · Frontend | Computer Engineering @ UT Austin | [@wjy0524](https://github.com/wjy0524) |
| **Isaac Choi** | ![KakaoTalk_Photo_2025-08-04-02-25-29](https://github.com/user-attachments/assets/5441256f-2cf7-41d0-8b06-4ac70c9122c6)| Frontend · WebGazer · ML Pipeline | Computer Science @ UT Austin | [@isaacchoi031014](https://github.com/isaacchoi031014) |


