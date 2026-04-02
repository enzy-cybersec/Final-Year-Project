import pandas as pd

df = pd.read_csv("/home/enzy/nids_project/data/attack_flows.csv", low_memory=False)
print(f"Rows before filtering: {len(df)}")

# ── Step 1: Remove external IPs and hypervisor ───────────────────────────
HYPERVISOR_IP = "192.168.66.101"

def is_valid(ip):
    return (
        str(ip).startswith('192.168.56.') or
        str(ip).startswith('192.168.66.')
    ) and str(ip) != HYPERVISOR_IP

mask = df['src_ip'].apply(is_valid) & df['dst_ip'].apply(is_valid)
df = df[mask].copy()
print(f"Rows after filtering: {len(df)}")

# ── Step 2: Define IPs ────────────────────────────────────────────────────
ATTACKER_IP = "192.168.66.100"  # attacker machine
WRK1_IP     = "192.168.56.200"  # compromised workstation (Chisel client)
DC01_IP     = "192.168.56.10"   # domain controller (attack target)
SVR1_IP     = "192.168.56.100"  # web server (initial access point)

df['label'] = 0

# Condition 1: Any flow directly involving attacker machine
# (covers initial SVR1 access + receiving Chisel tunnel from WRK1)
direct_attack = (
    (df['src_ip'] == ATTACKER_IP) |
    (df['dst_ip'] == ATTACKER_IP)
)

# Condition 2: WRK1 ↔ DC01 — tunnelled attacker traffic
# Attacker controls WRK1 via Chisel and uses it to attack DC01
# WRK1 → DC01 appears as legitimate internal traffic but is attacker-controlled
wrk1_to_dc = (
    ((df['src_ip'] == WRK1_IP) & (df['dst_ip'] == DC01_IP)) |
    ((df['src_ip'] == DC01_IP) & (df['dst_ip'] == WRK1_IP))
)

# Note: WRK1 ↔ SVR1 is intentionally NOT flagged (legitimate web traffic)

df.loc[direct_attack | wrk1_to_dc, 'label'] = 1

# ── Step 3: Breakdown ─────────────────────────────────────────────────────
print(f"\nTotal flows:   {len(df)}")
print(f"Normal flows:  {(df['label']==0).sum()}")
print(f"Attack flows:  {(df['label']==1).sum()}")
print(f"Attack ratio:  {(df['label']==1).sum()/len(df)*100:.1f}%")

print("\nAttack breakdown:")
print(f"  Direct attacker (66.100):          {direct_attack.sum()}")
print(f"  Chisel tunnel WRK1↔DC01 (56.200↔56.10): {wrk1_to_dc.sum()}")

# ── Step 4: Save ──────────────────────────────────────────────────────────
df.to_csv("/home/enzy/nids_project/data/attack_flows_labelled.csv", index=False)
print("\n[+] Saved: attack_flows_labelled.csv")