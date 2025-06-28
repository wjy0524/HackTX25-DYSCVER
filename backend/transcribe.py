# backend/transcribe.py

from transformers import pipeline

# 1) 파이프라인 한 번만 생성
asr_pipeline = pipeline(
    task="automatic-speech-recognition",
    model="openai/whisper-medium",
    device=0,           # GPU 사용 시 0, CPU만 쓸 땐 "cpu"
    chunk_length_s=30,  # 긴 파일은 30초 단위로 자름
)

def transcribe_korean_audio(file_path: str) -> str:
    """
    file_path: 전사할 오디오 파일 경로
    반환값: 전사된 전체 텍스트
    """
    result = asr_pipeline(file_path)
    return result["text"]

#model="openai/whisper-medium" 외에 tiny, small, large 등 원하는 크기로 바꿀 수 있습니다.
#chunk_length_s 는 길이가 긴 파일을 잘게 나누어 처리할 때 유용합니다.
#예시
#if __name__ == "__main__":
    #path = "samples/speech.mp3"
    #text = transcribe_korean_audio(path)
    #print("── 전사 결과 ──")
   # print(text)