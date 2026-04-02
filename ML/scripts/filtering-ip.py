import pandas as pd

df = pd.read_csv("/home/enzy/nids_project/data/attack_flows.csv", low_memory=False)

# Check if 192.168.66.100 is the attacker (high outbound to internal network)
print("=== Where does 192.168.66.100 send traffic? ===")
att = df[df['src_ip'] == '192.168.66.100']
print(att['dst_ip'].value_counts().head(10))

print("\n=== Where does 192.168.56.200 send traffic? ===")
wrk = df[df['src_ip'] == '192.168.56.200']
print(wrk['dst_ip'].value_counts().head(10))

print("\n=== HTTP traffic destinations (port 80/443) ===")
http = df[df['dst_port'].isin([80, 443, 8080, 8443])]
print(http[['src_ip','dst_ip','dst_port','bidirectional_bytes']].head(15).to_string())

print("\n=== Flows involving 192.168.56.10 (possible DC01) ===")
dc = df[(df['src_ip'] == '192.168.56.10') | (df['dst_ip'] == '192.168.56.10')]
print(f"Total flows: {len(dc)}")
print(dc['dst_port'].value_counts().head(10))