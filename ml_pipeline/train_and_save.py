# ml_pipeline/train_and_save.py


import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, roc_auc_score
import joblib


# ----------------------------------------------------------
# Load dataset
# ----------------------------------------------------------
# The dataset contains columns:
# words_read, duration_seconds, accuracy, comprehension_correct, dyslexia_label
df = pd.read_csv("labeled_data.csv")


# ----------------------------------------------------------
# Create derived (calculated) features
# ----------------------------------------------------------
# TOTAL_Q_PER_USER = number of comprehension questions per test


TOTAL_Q_PER_USER = 6


# wpm: words per minute (reading speed)
df["wpm"] = df["words_read"] / (df["duration_seconds"] / 60)


# comprehension_rate: ratio of correctly answered comprehension questions
df["comprehension_rate"] = df["comprehension_correct"] / TOTAL_Q_PER_USER


# ----------------------------------------------------------
# 3️⃣ Split features (X) and target (y)


# Select features that most influence dyslexia prediction
X = df[["wpm", "accuracy", "comprehension_rate"]]
# The target is dyslexia_label (1 = dyslexia risk, 0 = non-risk)
y = df["dyslexia_label"]


# ----------------------------------------------------------
# Train/test split
X_train, X_test, y_train, y_test = train_test_split(
   X, y, test_size=0.2, stratify=y, random_state=42
)


# Train Random Forest with hyperparameter tuning
# We test different combinations of parameters to find the best model
param_grid = {
   "n_estimators": [50, 100, 200],   # number of trees
   "max_depth": [None, 5, 10],       # tree depth (None = full depth)
}


clf = GridSearchCV(
   RandomForestClassifier(random_state=42),
   param_grid,
   cv=3,                 # 3-fold cross-validation
   scoring="roc_auc",    # evaluate based on AUC (probability quality)
   n_jobs=-1             # use all CPU cores
)


clf.fit(X_train, y_train)


# Evaluate model performance
y_pred = clf.predict(X_test)  # predicted labels (0 or 1)
y_prob = clf.predict_proba(X_test)[:, 1]  # predicted probabilities (0~1)


print("🔹 Classification Report:")
print(classification_report(y_test, y_pred))
print("🔹 ROC AUC Score:", roc_auc_score(y_test, y_prob))


# Save best model to file
joblib.dump(clf.best_estimator_, "best_dyslexia_rf.joblib")
print("🎉 Model saved as best_dyslexia_rf.joblib")