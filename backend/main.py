import os
import json
import tempfile
import subprocess
import wave
from pathlib import Path

from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib

from openai import OpenAI
from dotenv import load_dotenv
load_dotenv()

# Local modules
from transcribe import transcribe_audio       # formerly transcribe_korean_audio
from similarity_percent import dist           # Levenshtein similarity
from utils import compute_eye_metrics

# Load pre-trained dyslexia model
dyslexia_model = joblib.load("../ml_pipeline/best_dyslexia_rf.joblib")
TOTAL_Q_PER_USER = 6

# Initialize OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Create FastAPI app
app = FastAPI()

# CORS for Flutter web app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
    allow_credentials=True,
)


# ----------------------------- MODELS -----------------------------

class UserInfo(BaseModel):
    age: int
    gender: str
    native_language: str


# ----------------------------- ENDPOINTS -----------------------------

@app.post("/get-passages")
async def get_passages(info: UserInfo):
    """
    Generate 3 reading passages based on user's demographic information
    (age, gender, native language) using GPT.
    """
    system_prompt = (
        "You are a professional reading passage generator for dyslexia research.\n"
        "Given a JSON input containing the user's demographic information "
        "(age, gender, native language), create three age-appropriate reading passages.\n"
        "Return ONLY pure JSON with a single top-level key `passages`. "
        "Do not include any explanations, notes, or additional text."
    )

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": json.dumps(info.dict())}
        ]
    )
    raw = response.choices[0].message.content
    print("▶ GPT raw response:", raw)

    try:
        passages = json.loads(raw)["passages"]
    except (json.JSONDecodeError, KeyError) as e:
        raise HTTPException(status_code=500, detail=f"Failed to parse GPT passages: {e}")

    return {"passages": passages}


@app.post("/reading_test")
async def reading_test(
    expected: str = Form(..., description="Reference text"),
    eye_data: str = Form(...),
    audio: UploadFile = File(..., description="Recorded audio file (.webm, .wav, etc.)")
):
    """
    Receive a user’s recorded reading audio, transcribe it via Whisper,
    compute similarity to the reference text, and return reading metrics.
    """
    # 1) Save temporary input file
    suffix = Path(audio.filename).suffix or ".webm"
    tmp_input = tempfile.NamedTemporaryFile(delete=False, suffix=suffix)
    content = await audio.read()
    tmp_input.write(content)
    tmp_input.close()
    input_path = tmp_input.name

    # 2) Convert audio to 16kHz mono WAV (Whisper compatible)
    tmp_wav = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")
    wav_path = tmp_wav.name
    try:
        subprocess.run(
            ["ffmpeg", "-y", "-i", input_path, "-ar", "16000", "-ac", "1", wav_path],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
    except subprocess.CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Audio conversion failed: {e}")

    # 3) Speech-to-text transcription
    recognized_text = transcribe_audio(wav_path)

    # 4) Compute Levenshtein-based similarity
    accuracy = dist(expected.strip(), recognized_text.strip())

    # 5) Count words
    words_read = len(recognized_text.strip().split())

    # 6) Compute audio duration (seconds)
    with wave.open(wav_path, "rb") as wf:
        frames = wf.getnframes()
        rate = wf.getframerate()
        duration_seconds = int(frames / float(rate))

    # 7) Parse gaze data and compute eye-tracking metrics
    try:
        gaze_points = json.loads(eye_data)
    except json.JSONDecodeError:
        gaze_points = []
    fixation_count, avg_fix_dur, regression_count = compute_eye_metrics(gaze_points)

    # 8) Compute additional derived metrics
    cognitive_load = (sum(pt['t'] for pt in gaze_points) / len(gaze_points)) if gaze_points else 0
    fluency_score = words_read / (regression_count + 1)

    # 9) Return all computed results
    return JSONResponse({
        "accuracy": accuracy,                 # 0–100%
        "words_read": words_read,
        "duration_seconds": duration_seconds,
        "fixation_count": fixation_count,
        "avg_fixation_duration": avg_fix_dur, # milliseconds
        "regression_count": regression_count,
        "cognitive_load": cognitive_load,
        "fluency_score": fluency_score,
    })


@app.post("/get-comprehension-material")
async def get_comprehension_material(info: UserInfo):
    """
    Generate 3 comprehension passages and 2 multiple-choice questions per passage.
    """
    system_prompt = """
You are an expert in generating comprehension passages and 4-choice questions for dyslexia screening.
Given user demographic information (age, gender, native language) in JSON format,
create three passages (150–200 words each) and two multiple-choice questions per passage.
Each question must strictly follow this JSON structure:

{
  "question": "Question text",
  "options": ["Option 1", "Option 2", "Option 3", "Option 4"],
  "answer": 2
}

Return ONLY pure JSON with a single top-level key `comprehensions`.
Do not include explanations, markdown, or additional text.
    """

    res = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": json.dumps(info.dict())},
        ],
    )
    raw = res.choices[0].message.content
    try:
        data = json.loads(raw)
    except Exception as e:
        raise HTTPException(500, f"Failed to parse comprehension materials: {e}")

    return JSONResponse(data)


# ----------------------------- DYSLEXIA PREDICTION -----------------------------
@app.post("/predict_dyslexia")
def predict_dyslexia(data: dict):
    wpm = data["wpm"]
    accuracy = data["accuracy"]
    comprehension_rate = data["comprehension_rate"]
    
    print(f"Received → wpm={wpm:.1f}, accuracy={accuracy:.1f}, comp_rate={comprehension_rate:.2f}")

    X = [[wpm, accuracy, comprehension_rate]]
    model = joblib.load("../ml_pipeline/best_dyslexia_rf.joblib")
    prob = model.predict_proba(X)[0][1]  # Probability of dyslexia

    return {"probability": float(prob)}


# ----------------------------- FINAL EVALUATION -----------------------------

@app.post("/final-evaluate")
async def final_evaluate(
    expected: str = Form(...),
    recognized: str = Form(...),
    duration_seconds: int = Form(...),
    comprehension_correct: int = Form(...),
):
    """
    Combine reading + comprehension results to compute dyslexia probability.
    Called only after both stages of the test are finished.
    """
    # 1️⃣ Compute reading accuracy
    accuracy = lev.ratio(expected.strip(), recognized.strip()) * 100
    wpm = len(recognized.split()) / (duration_seconds / 60)
    comprehension_rate = comprehension_correct / 2  # 2 questions per test

    # 2️⃣ Run the ML model
    X_new = [[wpm, accuracy, comprehension_rate]]
    prob = float(dyslexia_model.predict_proba(X_new)[0, 1])
    prob = max(0, min(prob, 1))

    # 3️⃣ Interpret risk level
    if prob < 0.4:
        level = "Low"
    elif prob < 0.7:
        level = "Moderate"
    else:
        level = "High"

    # 4️⃣ Print to terminal
    print("──────────── FINAL EVALUATION ────────────")
    print(f"✅ Accuracy: {accuracy:.1f}%")
    print(f"⏱️  Duration: {duration_seconds}s")
    print(f"🧩 Comprehension: {comprehension_correct}/2")
    print(f"📊 Predicted Dyslexia Probability: {prob:.3f} ({level} Risk)")
    print("──────────────────────────────────────────")

    # 5️⃣ Return result to frontend
    return {
        "accuracy": round(accuracy, 2),
        "duration_seconds": duration_seconds,
        "comprehension_correct": comprehension_correct,
        "dyslexia_probability": round(prob, 3),
        "risk_level": level
    }