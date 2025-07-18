# backend/utils.py
import math
from typing import List, Dict, Tuple

# 화면 좌표 상, 고정(fixation) 판정 최소 이동 거리 기준 (pixel 단위)
SOME_THRESHOLD = 20.0

def compute_eye_metrics(gaze_points):
    # 1) None 이 아닌 포인트만 필터
    clean = [pt for pt in gaze_points
             if pt.get('x') is not None and pt.get('y') is not None]
    if len(clean) < 2:
        return 0, 0.0, 0

    # 2) 시선 고정(fixation)·역행(regression) 계산 예시
    fixation_count = 0
    regression_count = 0
    total_fix_dur = 0

    prev = clean[0]
    for pt in clean[1:]:
        dx = pt['x'] - prev['x']
        dy = pt['y'] - prev['y']
        # 예: 움직임이 작으면 고정, 뒤로 움직이면 역행
        dist = (dx*dx + dy*dy)**0.5
        if dist < SOME_THRESHOLD:
            fixation_count += 1
            total_fix_dur += pt['t'] - prev['t']
        elif dx < 0:
            regression_count += 1
        prev = pt

    avg_fix_dur = total_fix_dur / fixation_count if fixation_count else 0.0
    return fixation_count, avg_fix_dur, regression_count