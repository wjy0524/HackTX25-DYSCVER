# backend/main.py

from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse
from pathlib import Path
import tempfile, shutil

from backend.transcribe import transcribe_korean_audio
from backend.similarity_percent import score_reading

app = FastAPI()

@app.post("/reading_test")
async def reading_test(
    expected: str = Form(..., description="기준 문장"),
    audio: UploadFile = File(..., description="유저가 읽은 오디오 파일 (WAV/MP3 등)")
):
    # 1) 업로드된 오디오를 임시 파일로 저장
    suffix = Path(audio.filename).suffix or ".wav"
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
    tmp_path = tmp.name
    try:
        content = await audio.read()
        tmp.write(content)
        tmp.close()

        # 2) Whisper 파이프라인을 이용해 전사
        recognized = transcribe_korean_audio(tmp_path)

        # 3) Levenshtein 기반 유사도 계산 (0~100%)
        accuracy = score_reading(expected.strip(), recognized.strip())

        # 4) 결과 반환
        return {
            "expected": expected,
            "recognized": recognized,
            "accuracy": accuracy
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Reading test failed: {e}")

    finally:
        # 5) 임시 파일은 반드시 지워 줍니다
        Path(tmp_path).unlink(missing_ok=True)