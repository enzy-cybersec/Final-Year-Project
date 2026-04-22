#!/usr/bin/env python3
# isolation_forest_comprehensive_analysis.py

import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import IsolationForest
from sklearn.metrics import confusion_matrix, classification_report, f1_score

# === 1. Load data ===
train_path = "data/train_set_v3.csv"
test_path  = "data/test_set_v3.csv"

train = pd.read_csv(train_path, low_memory=False)
test  = pd.read_csv(test_path,  low_memory=False)

print(f"Train shape: {train.shape}")
print(f"Test  shape: {test.shape}")
print("Test ground truth distribution:\n", test["label"].value_counts())

# === 2. Ground Truth Isolation & Cleaning ===
# Extract labels as our 'Hidden Key' for evaluation
y_train_ground = train["label"]
y_test_ground  = test["label"]

# Drop labels so the model is mathematically unsupervised
X_train = train.drop(columns=["label"], errors="ignore")
X_test  = test.drop(columns=["label"], errors="ignore")

# Define non-numeric/metadata columns to drop for training
cols_to_drop = [
    "id", "expiration_id", "src_ip", "dst_ip",
    "src_mac", "dst_mac", "src_oui", "dst_oui",
    "application_name", "application_category_name",
    "requested_server_name", "client_fingerprint",
    "server_fingerprint", "user_agent", "content_type"
]
X_train = X_train.drop(columns=cols_to_drop, errors="ignore")
X_test  = X_test.drop(columns=cols_to_drop, errors="ignore")

# Handle inf / NaN - critical for Fedora/Python 3.14 stability
X_train = X_train.replace([np.inf, -np.inf], np.nan).dropna()
X_test  = X_test.replace([np.inf, -np.inf], np.nan).dropna()

# Realign ground truth labels with cleaned feature indices
y_train_ground = y_train_ground.loc[X_train.index]
y_test_ground  = y_test_ground.loc[X_test.index]

print(f"After cleaning - Train: {X_train.shape}, Test: {X_test.shape}")

# === 3. Scale features ===
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled  = scaler.transform(X_test)

# === 4. Train Isolation Forest (Unsupervised) ===
iso = IsolationForest(
    n_estimators=200,
    contamination="auto",
    random_state=42,
    n_jobs=-1
)
iso.fit(X_train_scaled)

# === 5. Predict (Blind to labels) ===
y_pred_raw = iso.predict(X_test_scaled)
y_pred = np.where(y_pred_raw == 1, 0, 1)  # Map 1:Normal, -1:Anomaly to 0:Normal, 1:Anomaly

# === 6. Performance Evaluation ===
cm = confusion_matrix(y_test_ground, y_pred)
tn, fp_count, fn, tp = cm.ravel()
fpr = fp_count / (fp_count + tn) if (fp_count + tn) > 0 else 0.0

print("\n=== PERFORMANCE METRICS ===")
print(f"Confusion Matrix:\n{cm}")
print(f"\nF1-Score: {f1_score(y_test_ground, y_pred):.4f}")
print(f"False Positive Rate (FPR): {fpr:.4f}")
print("\nClassification Report:")
print(classification_report(y_test_ground, y_pred, digits=4))

# === 7. Comprehensive False Positive Analysis ===
print("\n=== DETAILED FALSE POSITIVE ANALYSIS ===")

# Reload full metadata for analysis
test_full = pd.read_csv(test_path, low_memory=False).loc[X_test.index].copy()
test_full["y_true"] = y_test_ground.values
test_full["y_pred"] = y_pred

# Filter for FPs: predicted anomaly (1) but actually normal (0)
fp = test_full[(test_full["y_true"] == 0) & (test_full["y_pred"] == 1)]
print(f"Total False Positives found: {len(fp)}")

if not fp.empty:
    # Breakdown by standard network identifiers
    for col in ["src_ip", "dst_ip", "dst_port", "application_name"]:
        print(f"\nTop 10 FP by {col}:")
        print(fp[col].value_counts().head(10))

    # Path Breakdown: SRC -> DST + APP
    print("\nTop 15 src_ip → dst_ip → application_name (by FP count):")
    fp_path = fp.groupby(["src_ip", "dst_ip", "application_name"]).size().reset_index(name="count")
    print(fp_path.sort_values("count", ascending=False).head(15).to_string(index=False))

    # Sample flows for manual verification
    print("\nSample FP flows (Verification):")
    cols_view = ["src_ip", "dst_ip", "src_port", "dst_port", "protocol", "application_name"]
    print(fp.sample(min(10, len(fp)), random_state=42)[cols_view])

# === 8. Protocol-Level Breakdown Function ===
def protocol_breakdown(df, top_n=20):
    detected = df[df["y_pred"] == 1].copy()
    if detected.empty: return
    
    detected["_tp"] = (detected["y_true"] == 1).astype(int)
    detected["_fp"] = (detected["y_true"] == 0).astype(int)

    for group_col, label in [("application_name", "App Protocol"), ("protocol", "Transport Proto")]:
        breakdown = detected.groupby(group_col).agg(
            total_detected=("y_pred", "count"),
            true_positives=("_tp", "sum"),
            false_positives=("_fp", "sum")
        ).reset_index()
        
        breakdown["fp_rate_%"] = (breakdown["false_positives"] / breakdown["total_detected"] * 100).round(2)
        print(f"\n{label} - FP vs Detected (Top {top_n})")
        print(breakdown.sort_values("total_detected", ascending=False).head(top_n).to_string(index=False))

protocol_breakdown(test_full)
