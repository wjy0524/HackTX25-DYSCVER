# ml_pipeline/train_and_save.py
import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, roc_auc_score
import joblib

# 1) 데이터 로드
df = pd.read_csv("labeled_data.csv")  
# → 컬럼: words_read, duration_seconds, accuracy, comprehension_correct, dyslexia_label

# 2) 파생 변수
TOTAL_Q_PER_USER = 2  # 이해도 테스트 당 문제 수
df["wpm"]                = df["words_read"] / (df["duration_seconds"]/60)
df["comprehension_rate"] = df["comprehension_correct"] / TOTAL_Q_PER_USER

# 3) 특성/타깃 분리
X = df[["wpm", "accuracy", "comprehension_rate"]]
y = df["dyslexia_label"]  # 0 or 1

# 4) 학습/검증 세트
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=42
)

# 5) 모델 & 하이퍼파라미터 탐색
param_grid = {
    "n_estimators": [50,100,200],
    "max_depth":    [None, 5, 10],
}
clf = GridSearchCV(
    RandomForestClassifier(random_state=42),
    param_grid, cv=3, scoring="roc_auc", n_jobs=-1
)
clf.fit(X_train, y_train)

# 6) 평가
y_pred = clf.predict(X_test)
print(classification_report(y_test, y_pred))
print("ROC AUC:", roc_auc_score(y_test, clf.predict_proba(X_test)[:,1]))

# 7) 저장
joblib.dump(clf.best_estimator_, "best_dyslexia_rf.joblib")
print("🎉 모델을 best_dyslexia_rf.joblib 로 저장했습니다.")