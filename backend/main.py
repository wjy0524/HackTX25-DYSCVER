import os
import json
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from pathlib import Path
import tempfile
import subprocess
import wave

from fastapi.middleware.cors import CORSMiddleware

# STT 전사 함수 (별도 파일)
from transcribe import transcribe_korean_audio
# 유사도 계산 함수 (별도 파일)
from similarity_percent import dist
from utils import compute_eye_metrics

from openai import OpenAI
from dotenv import load_dotenv
load_dotenv()  # .env 파일을 로드합니다

# 새 1.x 인터페이스용 클라이언트 인스턴스 생성
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Flutter 웹 호스트
    allow_methods=["*"],
    allow_headers=["*"],
    allow_credentials=True,
)

class UserInfo(BaseModel):
    age: int
    gender: str
    native_language: str

@app.post("/get-passages")
async def get_passages(info: UserInfo):
    """
    사용자의 인구통계 정보에 맞춰 GPT로부터 3개의 읽기 지문을 생성
    """
    system_prompt = ( 
        "당신은 난독증 연구를 위한 읽기 지문 생성 전문가입니다.\n"
        "입력으로 사용자의 인구통계 정보(나이, 성별, 모국어)를 JSON 형태로 받으면,\n"
        "연령대에 맞는 지문 3개를 생성해 주세요.\n"
        "반드시 최상위에 `passages` 키만 포함된 순수 JSON 형식으로 출력하세요. "
        "추가 설명은 절대 포함하지 마세요."
    )
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user",   "content": json.dumps(info.dict())}
        ]
    )
    raw = response.choices[0].message.content
    print("▶ GPT 응답(raw):", raw)
    # 파싱 및 에러 처리
    try:
        passages = json.loads(raw)["passages"]
    except (json.JSONDecodeError, KeyError) as e:
        raise HTTPException(status_code=500, detail=f"Passages 파싱 오류: {e}")
    return {"passages": passages}
    

@app.post("/reading_test")
async def reading_test(
    expected: str = Form(..., description="기준 문장"),
    eye_data: str = Form(...),
    audio: UploadFile = File(..., description="사용자 녹음 파일(.webm 등)")
):
    """
    사용자 녹음 파일을 받아 Whisper 전사 후 유사도 계산
    """
    # 1) 웹엠(.webm) 파일 임시 저장
    suffix = Path(audio.filename).suffix or ".webm"
    tmp_input = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
    input_path = tmp_input.name
    content = await audio.read()
    tmp_input.write(content)
    tmp_input.close()

    # 2) Whisper 호환용 WAV로 변환 (16kHz, 모노)
    tmp_wav = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
    wav_path = tmp_wav.name
    try:
        subprocess.run(
            [
                "ffmpeg", "-y",
                "-i", input_path,
                "-ar", "16000",
                "-ac", "1",
                wav_path
            ],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"오디오 변환 실패: {e}")

    # 3) STT 전사 수행
    recognized_text = transcribe_korean_audio(wav_path)

    # 4) Levenshtein 기반 유사도 계산
    accuracy = dist(expected.strip(), recognized_text.strip())

    # 5) 단어 수 세기
    words_read = len(recognized_text.strip().split())

    # 6) 오디오 길이(초) 계산
    with wave.open(wav_path, "rb") as wf:
        frames = wf.getnframes()
        rate   = wf.getframerate()
        duration_seconds = int(frames / float(rate))
    # 7) eye_data 파싱 & 메트릭 계산
    try:
        gaze_points = json.loads(eye_data)
    except json.JSONDecodeError:
        gaze_points = []
    fixation_count, avg_fix_dur, regression_count = compute_eye_metrics(gaze_points)

    # 추가 지표
    cognitive_load = (sum(pt['t'] for pt in gaze_points) / len(gaze_points)) \
                     if gaze_points else 0
    fluency_score  = words_read / (regression_count + 1)


# 8) 결과 반환 (accuracy, words_read, duration_seconds 모두 포함)
    return JSONResponse({
        "accuracy":             accuracy,            # 0~100%
        "words_read":           words_read,
        "duration_seconds":     duration_seconds,
        "fixation_count":       fixation_count,
        "avg_fixation_duration": avg_fix_dur,         # ms 단위
        "regression_count":     regression_count,
        "cognitive_load":       cognitive_load,      # 대략적 부하 지표
        "fluency_score":        fluency_score,       # 유창성 지표
    })