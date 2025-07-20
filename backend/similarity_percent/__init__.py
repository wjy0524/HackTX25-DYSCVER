import Levenshtein as lev

def dist(expected: str, recognized: str) -> float:
    """
    두 문장 간의 Levenshtein 유사도를 백분율(0~100%)로 반환합니다.
    lev.ratio()를 사용해 0~1 사이의 유사도를 계산한 뒤, 백분율로 변환.
    """
    # ratio() returns a float in [0,1]
    similarity_percentage = lev.ratio(expected, recognized) * 100

    print(f"🎯 Expected:   {expected}")
    print(f"🗣️  Recognized: {recognized}")
    print(f"✅ Accuracy:   {similarity_percentage:.1f}%")

    return similarity_percentage
