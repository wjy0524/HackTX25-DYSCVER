import os
import json
import openai
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from pathlib import Path
import tempfile
import subprocess

from fastapi.middleware.cors import CORSMiddleware

# STT 전사 함수 (별도 파일)
from backend.transcribe import transcribe_korean_audio
# 유사도 계산 함수 (별도 파일)
from backend.similarity_percent import dist

# .env 파일에 API 키를 저장하고 로드하려면 python-dotenv 사용
from dotenv import load_dotenv
load_dotenv()  # .env 파일을 로드합니다

# 환경 변수에서 OpenAI API 키 로드
openai.api_key = os.getenv("OPENAI_API_KEY")

app = FastAPI()

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
        "입력으로 사용자의 인구통계학적 정보(예: 나이, 성별, 모국어)를 JSON 형태로 받으면,\n"
        "연령대에 맞춘 지문 3개를 JSON 포맷으로 생성해 주세요."
    )
    # GPT 호출
    response = openai.ChatCompletion.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": json.dumps(info.dict())}
        ]
    )
    # 반환된 JSON 문자열 파싱
    try:
        passages = json.loads(response.choices[0].message.content)["passages"]
    except (json.JSONDecodeError, KeyError) as e:
        raise HTTPException(status_code=500, detail=f"Passages 파싱 오류: {e}")
    return {"passages": passages}

@app.post("/reading_test")
async def reading_test(
    expected: str = Form(..., description="기준 문장"),
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

    # 5) 결과 반환
    return JSONResponse({"accuracy": accuracy})