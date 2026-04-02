import pandas as pd

df = pd.read_csv("/home/enzy/nids_project/data/attack_flows.csv", low_memory=False)

print("=== ALL COLUMN NAMES ===")
for i, col in enumerate(df.columns.tolist()):
    print(f"{i}: {col}")

print("\n=== FIRST ROW VALUES ===")
print(df.iloc[0].to_string())