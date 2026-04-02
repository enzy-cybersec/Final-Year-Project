import pandas as pd

df = pd.read_csv("/home/enzy/nids_project/data/attack_flows.csv", low_memory=False)

print("=== TOP 15 SOURCE IPs ===")
print(df['src_ip'].value_counts().head(15))

print("\n=== TOP 15 DESTINATION IPs ===")
print(df['dst_ip'].value_counts().head(15))

print("\n=== ALL UNIQUE IPs (both src and dst) ===")
all_ips = pd.concat([df['src_ip'], df['dst_ip']]).value_counts()
print(all_ips.head(20))

print("\n=== HTTP/S flows destination IPs ===")
http = df[df['dst_port'].isin([80, 443, 8080, 8443])]
print(http['dst_ip'].value_counts().head(10))