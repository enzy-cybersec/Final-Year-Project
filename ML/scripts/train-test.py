import pandas as pd
from sklearn.model_selection import train_test_split

# Load both datasets
normal = pd.read_csv("/home/enzy/nids_project/data/normal_flows_clean.csv", low_memory=False)
attack = pd.read_csv("/home/enzy/nids_project/data/attack_flows_clean.csv", low_memory=False)

# Split normal flows 80/20
normal_train, normal_test = train_test_split(
    normal,
    test_size=0.2,
    random_state=42
)

print(f"Training set (normal only): {len(normal_train)} flows")
print(f"Normal held out for test:   {len(normal_test)} flows")

# Build test set = held-out normal + all labelled attack flows
test_set = pd.concat([normal_test, attack], ignore_index=True)

# Shuffle the test set so normal/attack rows are mixed
test_set = test_set.sample(frac=1, random_state=42).reset_index(drop=True)

print(f"=== UNSUPERVISED DATASETS ===")
print(f"Training set (Baseline): {len(normal_train)} normal flows")
print(f"Test set (Evaluation):   {len(test_set)} total flows")
print(f"  - Held-out Normal:     {len(normal_test)}")
print(f"  - Unknown (Attack):    {len(attack)}")

# Save both
normal_train.to_csv("/home/enzy/nids_project/data/train_set_unsupervised.csv", index=False)
test_set.to_csv("/home/enzy/nids_project/data/test_set_unsupervised.csv", index=False)

print("\n[+] Saved: train_set_unsupervised.csv and test_set_unsupervised.csv")
