#!/usr/bin/env python3
# isolation_forest_run_fp_analysis.py
# Train + evaluate Isolation Forest and inspect false positives

import pandas as pd
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import IsolationForest
from sklearn.metrics import confusion_matrix, classification_report

# === 1. Load data ===
train_path = "data/train_set.csv"
test_path  = "data/test_set.csv"

train = pd.read_csv(train_path, low_memory=False)
test  = pd.read_csv(test_path,  low_memory=False)

print(f"Train shape: {train.shape}")
print(f"Test  shape: {test.shape}")
print("Test label distribution:\n", test["label"].value_counts())

# === 2. Split features / labels and clean ===
y_train = train["label"]
y_test  = test["label"]

X_train = train.drop(columns=["label"])
X_test  = test.drop(columns=["label"])

# Drop non-numeric / ID / metadata columns
cols_to_drop = [
    "id", "expiration_id", "src_ip", "dst_ip",
    "src_mac", "dst_mac", "src_oui", "dst_oui",
    "application_name", "application_category_name",
    "requested_server_name", "client_fingerprint",
    "server_fingerprint", "user_agent", "content_type"
]
X_train = X_train.drop(columns=cols_to_drop, errors="ignore")
X_test  = X_test.drop(columns=cols_to_drop, errors="ignore")

# Handle inf / NaN
X_train = X_train.replace([np.inf, -np.inf], np.nan).dropna()
X_test  = X_test.replace([np.inf, -np.inf], np.nan).dropna()

# Realign labels with cleaned feature indices
y_train = y_train.loc[X_train.index]
y_test  = y_test.loc[X_test.index]

print(f"After cleaning - Train: {X_train.shape}, Test: {X_test.shape}")

# === 3. Scale features ===
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled  = scaler.transform(X_test)

# === 4. Train Isolation Forest on NORMAL data only ===
iso = IsolationForest(
    n_estimators=200,
    contamination="auto",
    random_state=42,
    n_jobs=-1
)
iso.fit(X_train_scaled)

# === 5. Predict on test set ===
# IsolationForest: 1 = normal, -1 = anomaly
y_pred_raw = iso.predict(X_test_scaled)
y_pred = np.where(y_pred_raw == 1, 0, 1)  # map to 0=normal, 1=attack

cm = confusion_matrix(y_test, y_pred)
print("\nConfusion matrix:\n", cm)

print("\nClassification report:")
print(classification_report(y_test, y_pred, digits=4))

tn, fp_count, fn, tp = cm.ravel()
fpr = fp_count / (fp_count + tn) if (fp_count + tn) > 0 else 0.0
print(f"\nFalse Positive Rate (FPR): {fpr:.4f}")

# === 6. False positive analysis ===
print("\n=== FALSE POSITIVE ANALYSIS ===")

# Reload full test set (with IPs, ports, app names etc.)
test_full = pd.read_csv(test_path, low_memory=False)

# Align with cleaned X_test indices
test_full = test_full.loc[X_test.index].copy()
test_full["y_true"] = y_test.values
test_full["y_pred"] = y_pred

# False Positives: predicted attack (1) but actually normal (0)
fp = test_full[(test_full["y_true"] == 0) & (test_full["y_pred"] == 1)]
print(f"False positives: {len(fp)}")

if len(fp) > 0:
    print("\nFP by src_ip:")
    print(fp["src_ip"].value_counts().head(10))

    print("\nFP by dst_ip:")
    print(fp["dst_ip"].value_counts().head(10))

    print("\nFP by dst_port:")
    print(fp["dst_port"].value_counts().head(10))

    print("\nFP by application_name:")
    print(fp["application_name"].value_counts().head(10))

    print("\nSample FP flows:")
    print(
        fp.sample(min(10, len(fp)), random_state=42)[[
            "src_ip", "dst_ip", "src_port", "dst_port",
            "protocol", "bidirectional_bytes", "bidirectional_packets",
            "application_name", "application_category_name"
        ]]
    )

    # === 7. Detailed FP breakdown: src → dst + protocol ===
    print("\n=== FALSE POSITIVES: SRC → DST + PROTOCOL ===")

    fp_pairs = (
        fp.groupby(["src_ip", "dst_ip"])
          .size()
          .reset_index(name="count")
          .sort_values("count", ascending=False)
    )
    print("\nTop 15 src_ip → dst_ip pairs (by FP count):")
    print(fp_pairs.head(15).to_string(index=False))

    fp_pairs_port = (
        fp.groupby(["src_ip", "dst_ip", "dst_port"])
          .size()
          .reset_index(name="count")
          .sort_values("count", ascending=False)
    )
    print("\nTop 15 src_ip → dst_ip → dst_port (by FP count):")
    print(fp_pairs_port.head(15).to_string(index=False))

    fp_pairs_app = (
        fp.groupby(["src_ip", "dst_ip", "application_name"])
          .size()
          .reset_index(name="count")
          .sort_values("count", ascending=False)
    )
    print("\nTop 15 src_ip → dst_ip → application_name (by FP count):")
    print(fp_pairs_app.head(15).to_string(index=False))

else:
    print("No false positives found.")