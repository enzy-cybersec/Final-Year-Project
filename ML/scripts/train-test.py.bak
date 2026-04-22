import pandas as pd
from sklearn.model_selection import train_test_split

# Load both datasets
normal = pd.read_csv("/home/enzy/nids_project/data/normal_flows.csv", low_memory=False)
attack = pd.read_csv("/home/enzy/nids_project/data/attack_flows_labelled.csv", low_memory=False)

# Add label=0 to normal flows
normal['label'] = 0

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

print(f"\n=== FINAL DATASETS ===")
print(f"Training set:  {len(normal_train)} flows (all normal, label=0)")
print(f"Test set:      {len(test_set)} flows total")
print(f"  Normal:      {(test_set['label']==0).sum()}")
print(f"  Attack:      {(test_set['label']==1).sum()}")
print(f"  Attack ratio: {(test_set['label']==1).sum()/len(test_set)*100:.1f}%")

# Save both
normal_train.to_csv("/home/enzy/nids_project/data/train_set.csv", index=False)
test_set.to_csv("/home/enzy/nids_project/data/test_set.csv", index=False)
print("\n[+] Saved: train_set.csv and test_set.csv")