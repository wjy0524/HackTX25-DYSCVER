# Dystrace (난독증 데이터 수집 플랫폼) 

<img width="1144" height="760" alt="image" src="https://github.com/user-attachments/assets/455e2e3c-66b7-4144-9605-c7b2070173b8" />
DysTrace는 읽기 정확도, 음성 발화 패턴, 이해도 점수, 그리고 실시간 시선 추적 정보를 자동으로 수집 및 분석하여 난독증 연구와 임상 진단을 지원하는 웹 플랫폼입니다.

난독증은 그 유형이 다양하고 판단 기준이 명확하지 않아, 단순한 테스트만으로는 쉽게 판별하기 어렵습니다. Dystrace는 사용자의 읽기 정확도, 발화 내용, 이해도, 시선 추적 정보를 바탕으로 전문가가 보다 신뢰성 있는 판단을 내릴 수 있도록 다양한 데이터를 수집합니다.

사용자는 로그인 시 성별, 최종학력, 나이 등의 기본 정보를 입력하고, 나이에 맞는 수준의 지문을 읽게 됩니다. 읽는 과정은 음성으로 녹음되며, 실제 지문과의 정확도(accuracy)를 바탕으로 읽기 능력을 평가합니다.
또한 지문에 대한 독해 질문을 통해 이해도를 확인하고, 시선 추적을 통해 눈동자 움직임도 함께 기록합니다.

Dystrace는 난독증을 직접 진단하지 않지만, 다양한 신호를 바탕으로 종합적인 데이터셋을 구축해 전문가와 연구자들의 판단과 분석을 효과적으로 지원합니다.



# 🚀 주요 기능 
- **읽기 테스트**  
  - 사용자 연령에 맞는 지문 제시  
  - 마이크 녹음 및 시선 데이터 수집  
  - 정확도(Levenshtein), 속도(WPM), 고정 및 회귀 응시 횟수, 인지 부하 계산

- **이해도 테스트**  
  - GPT-4o-Mini로 객관식 문항 자동 생성  
  - 정답률 계산 및 기록 저장

- **클리닉 위치 & 정보**  
  - OpenStreetMap 기반 `flutter_map` 대화형 지도  
  - 주요 지원센터 리스트 & 웹 리소스 링크

- **사용자 프로필 & 기록 보기**  
  - Firebase Auth 회원가입/로그인  
  - Firestore에 결과 저장  
  - 나의 지난 모든 검사 기록과 전체 통계 비교


# 📦 기술 스택

- **프론트엔드**  
  - Flutter Web  
  - `flutter_map`, OpenStreetMap  
  - `firebase_auth`, `cloud_firestore`  
  - `flutter_widget_from_html_core` (리치 텍스트)

- **백엔드**  
  - FastAPI + Uvicorn  
  - Whisper 기반 STT → WAV 변환 (`ffmpeg`)  
  - Levenshtein 유사도 계산  
  - GPT-4o-Mini (지문·문항 생성)  
  - CORS 미들웨어 적용

- **머신러닝 (연구용)**  
  - Random Forest 난독증 위험 예측 모델 (joblib)

 
# 🛠️ 실행 방법

## 1. 백엔드 서버

### 가상환경 & 의존성 설치
```                   
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```                        

### .env 파일에 OpenAI 키 추가
* echo "OPENAI_API_KEY=sk-…" > .env

### .config_secret 폴더에 serviceAccountKey.json 추가
* .config_secret 폴더를 백엔드 안에 만들고 serviceAccountKey.json 파일 생성

Firebase Admin 키(JSON)는 backend/.config_secret/serviceAccountKey.json 에 위치
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

### 백엔드 실행 방법
```
cd backend
uvicorn main:app —reload
```

## 2. 프론트앤드 서버

### 프론트앤드 실행 방법
```
cd frontend
flutter clean
flutter pub get
flutter run -d chrome
```
## 3. ml_pipeline 서버

### 옵션: ml_pipeline 실행
```
cd ml_pipeline
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```


# 📸 주요 페이지

| 단계 | 미리보기 |
|------|----------|
| 메인 페이지 | <img width="1505" height="858" alt="Screenshot 2025-08-04 at 1 31 30 AM" src="https://github.com/user-attachments/assets/58be20e9-13c0-484c-853b-73804e908e28" /> |
| **캘리브레이션** | <img width="1505" height="858" alt="Screenshot 2025-08-04 at 1 32 43 AM" src="https://github.com/user-attachments/assets/b0964fbb-57e4-4087-82a1-b043b287f660" /> |
| 읽기 테스트 | <img width="1505" height="858" alt="Screenshot 2025-08-04 at 1 35 26 AM" src="https://github.com/user-attachments/assets/d0cd50f0-c82b-48b0-9de6-d0cb52ce4c47" /> |
| 이해도 문제 풀이 | <img width="1505" height="858" alt="Screenshot 2025-08-04 at 1 44 09 AM" src="https://github.com/user-attachments/assets/b3847990-9e71-4002-8e7b-af5eda18834c" /> |
| 히스토리 페이지 | <img width="1505" height="858" alt="Screenshot 2025-08-04 at 1 44 55 AM" src="https://github.com/user-attachments/assets/548367cb-8c9f-4d43-8f30-f7c95eacd8a8" /> |
| 통계 대시보드 | <img width="1505" height="858" alt="Screenshot 2025-08-04 at 1 45 18 AM" src="https://github.com/user-attachments/assets/4d04613b-cae9-4863-9997-0656c0f8b9c1" /> |
| 난독증 정보 | <img width="1505" height="858" alt="Screenshot 2025-08-04 at 1 45 47 AM" src="https://github.com/user-attachments/assets/ff8d6f51-f4db-4b6c-ab15-8ccbd4ee5943" /> |


# 🛠️ 개선점
1. 캘리브레이션 중 버튼이 가끔 눌리지 않는 문제가 발생함

2. Eye tracking으로 수집되는 데이터의 정확도가 낮음

3. 녹화 종료 후에도 빨간 점(시선 커서)이 화면에 남아 있음 → 제거 필요

4. 네비게이션 바가 없어 전체적인 라우팅 구조가 미흡함 → 추가 예정

5. 지도 API 서비스 연동 예정 (예: 캠퍼스 안내, 헬퍼 위치 표시 등)

6. 난독증 관련 게임 개발 예정 (진단 + 흥미 요소 결합)

7. ML 파이프라인 적용 계획 중:

    입력값: 읽기 속도, 정확도, 읽은 단어 수, 이해도 정답률

    출력값: 0 (정상), 1 (난독증 위험)

    현재 Eye Tracking 정보는 정확도가 낮아 제외됨

    이미 ml_pipeline은 구축 완료

    문제점: 학습에 필요한 정답으로 라벨링된 데이터셋이 없음. 관련 논문/자료도 부족

    참고로 Eye Tracking은 비교적 데이터셋이 존재함

    따라서 현재 웹 서비스에서는 ML 파이프라인을 활용하고 있지 않음

8. 관리자에게 문의하기 기능 필요 (문제 발생 시 유저 피드백용)

9. 챗봇 기능 추가 예정 (Q&A 및 네비게이션 도우미)

10. 현재 UI/UX가 앱 형식처럼 보여 웹사이트답지 않음 → 전체적인 디자인 전문화 필요


# 👥 개발자

| 이름 | 사진 | 역할 | 소속(전공) | GitHub |
|------|------|------|-----------|--------|
| **심가은** | <img src="docs/devs/sim_ga_eun.png" width="80" alt="심가은" /> | 백엔드 · UI/UX · 프론트엔드 | Computer Science @ USC | [@Sophiegs-cherry](https://github.com/Sophiegs-cherry) |
| **원재연** | <img src="docs/devs/won_jae_yeon.png" width="80" alt="원재연" /> | 백엔드 · WebGazer · ML Pipeline | Computer Engineering @ UT Austin | [@wjy0524](https://github.com/wjy0524) |
| **최태환** | ![KakaoTalk_Photo_2025-08-04-02-25-29](https://github.com/user-attachments/assets/5441256f-2cf7-41d0-8b06-4ac70c9122c6)| 프론트엔드 · WebGazer | Computer Science @ UT Austin | [@isaacchoi031014](https://github.com/isaacchoi031014) |


