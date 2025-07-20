# export_data.py
import os
import csv
import firebase_admin
from firebase_admin import credentials, firestore

# 1) 서비스 계정 키 파일 경로 지정
#    (GCP 콘솔에서 생성한 서비스 계정 JSON 파일)
SERVICE_ACCOUNT = os.getenv("GOOGLE_APPLICATION_CREDENTIALS", "path/to/serviceAccountKey.json")

# 2) Firebase Admin SDK 초기화
cred = credentials.Certificate(SERVICE_ACCOUNT)
firebase_admin.initialize_app(cred)
db = firestore.client()

# 3) CSV 파일 열기
with open("reading_results.csv", "w", newline="", encoding="utf-8") as f_read, \
     open("comprehension_results.csv", "w", newline="", encoding="utf-8") as f_comp:

    writer_read = csv.writer(f_read)
    writer_comp = csv.writer(f_comp)

    # 헤더 작성
    writer_read.writerow([
        "user_id",
        "timestamp",
        "accuracy",
        "words_read",
        "duration_seconds",
        "fluency_score",
        "cognitive_load",
      ])
    writer_comp.writerow([
        "user_id",
        "timestamp",
        "total_questions",
        "correct_answers",
        "correct_rate",
      ])

    # 4) users 컬렉션 순회
    users = db.collection("users").stream()
    for u in users:
        uid = u.id

        # 4a) 읽기 테스트 결과
        reads = db.collection("users") \
                  .document(uid) \
                  .collection("reading_results") \
                  .stream()
        for doc in reads:
            d = doc.to_dict()
            ts = d["timestamp"].isoformat()
            acc = d.get("accuracy", None)
            words = d.get("words_read", None)
            dur = d.get("duration_seconds", None)
            flu = d.get("fluency_score", None)
            cog = d.get("cognitive_load", None)
            writer_read.writerow([uid, ts, acc, words, dur, flu, cog])

        # 4b) 이해도 테스트 결과
        comps = db.collection("users") \
                  .document(uid) \
                  .collection("comprehension_results") \
                  .stream()
        for doc in comps:
            d = doc.to_dict()
            ts = d["timestamp"].isoformat()
            total = d.get("total_questions", None)
            corr  = d.get("correct_answers", None)
            rate  = (corr/total*100) if total else None
            writer_comp.writerow([uid, ts, total, corr, rate])

print("✅ Export complete: reading_results.csv, comprehension_results.csv")