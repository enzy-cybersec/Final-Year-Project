import pandas as pd
import numpy as np

# ── Step 1: Identifiers ──────────────────────────────────────────────────
ATTACKER_IP = "192.168.66.100"
WRK1_IP     = "192.168.56.200"
DC01_IP     = "192.168.56.10"
SVR1_IP     = "192.168.56.100"

WEB_PROTOCOLS = ['HTTP', 'HTTPS', 'SSL', 'TLS']
SMB_PROTOCOLS = ['NETBIOS.SMBV23', 'SMBV1', 'SMBV2', 'SMB']
DC_SENSITIVE  = WEB_PROTOCOLS + SMB_PROTOCOLS + ['LDAP', 'DCERPC', 'KERBEROS']

def apply_labels(df):
    # Ensure consistency
    df['application_name'] = df['application_name'].str.upper()
    df['label'] = 0
    
    # --- HEURISTIC CALCULATION ---
    # Legitimate SMB writes have high payload density.
    # Password sprays have low density (just headers/handshakes).
    # Adding 0.1 to avoid division by zero errors.
    df['bytes_per_packet'] = df['bidirectional_bytes'] / (df['bidirectional_packets'] + 0.1)

    # 1. Define Boolean Masks
    is_attacker = (df['src_ip'] == ATTACKER_IP) | (df['dst_ip'] == ATTACKER_IP)
    is_to_dc    = (df['src_ip'] == DC01_IP)     | (df['dst_ip'] == DC01_IP)
    is_to_svr1  = (df['src_ip'] == SVR1_IP)     | (df['dst_ip'] == SVR1_IP)
    is_smb      = df['application_name'].isin(SMB_PROTOCOLS)
    
    # 2. APPLICATION LOGIC (Hierarchical)
    
    # Rule A: SMB/Web/LDAP to Domain Controller is ALWAYS an attack.
    bad_dc_proto = df['application_name'].isin(DC_SENSITIVE)
    df.loc[is_to_dc & bad_dc_proto, 'label'] = 1
    
    # Rule B: SVR1 Heuristic Separation
    # If it's SMB to SVR1, check the density. 
    # Spray: Small, fast authentication attempts (< 150 bytes per packet).
    is_low_density = df['bytes_per_packet'] < 150
    df.loc[is_to_svr1 & is_smb & is_low_density, 'label'] = 1
    
    # Rule C: SVR1 Exemption for "Heavy" Traffic
    # If the bytes per packet are high (> 500), it's a file write/transfer.
    # We force this to 0 (Normal).
    is_heavy_traffic = df['bytes_per_packet'] > 500
    df.loc[is_to_svr1 & is_heavy_traffic, 'label'] = 0
    
    # Rule D: THE ATTACKER PRIORITY
    # Interaction with the attacker machine is always an attack.
    df.loc[is_attacker, 'label'] = 1
    
    return df

# ── Step 2: Load, Sanitise, and Save ──────────────────────────────────────
print("Refining Ground Truth v3: Separating Spray vs Write...")
df_n = pd.read_csv("/home/enzy/nids_project/data/normal_flows_clean.csv", low_memory=False)
df_a = pd.read_csv("/home/enzy/nids_project/data/attack_flows_clean.csv", low_memory=False)

df_n = apply_labels(df_n)
df_a = apply_labels(df_a)

# Training Set (Purely Benign)
clean_normal = df_n[df_n['label'] == 0].copy()
leaked_attacks = df_n[df_n['label'] == 1].copy()

train_set = clean_normal.sample(frac=0.8, random_state=42)
test_set = pd.concat([
    clean_normal.drop(train_set.index), 
    leaked_attacks, 
    df_a
], ignore_index=True)

test_set = test_set.sample(frac=1, random_state=42).reset_index(drop=True)

train_set.to_csv("/home/enzy/nids_project/data/train_set_v4.csv", index=False)
test_set.to_csv("/home/enzy/nids_project/data/test_set_v4.csv", index=False)

print(f"\n[+] Success: Ground Truth v3 saved.")
print(f"Attack flows in test set: {test_set['label'].sum()}")
