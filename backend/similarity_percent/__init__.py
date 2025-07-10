import Levenshtein as lev

def score_reading(expected, recognized):
    """
    두 문장 간의 Levenshtein 유사도를 백분율(0~100%)로 반환합니다.
    """
    edit_distance = lev.distance(expected, recognized)
    origin_len = len(expected)
    comp_len = len(recognized)
    total_length = (origin_len + comp_len) / 2

    # 유사도가 음수가 되는 경우를 방지
    if edit_distance > total_length:
        similarity_percentage = 0
    else:
        similarity_percentage = (1 - (edit_distance / total_length)) * 100

    print(f"🎯 Expected: {expected}")
    print(f"🗣️  Recognized: {recognized}")
    print(f"✅ Accuracy: {similarity_percentage}%")

    return similarity_percentage
