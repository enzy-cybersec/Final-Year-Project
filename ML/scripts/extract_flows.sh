#!/bin/bash
# extract_flows.sh - NFStream version (no Java needed)

PCAP_DIR=~/nids_project/pcaps
DATA_DIR=~/nids_project/data
NORMAL_PCAP="normal_ad_traffic.pcap"   # <-- update to your filename
ATTACK_PCAP="attack_traffic.pcap"       # <-- update to your filename

source ~/nids_project/venv/bin/activate

echo "[*] Extracting normal traffic flows..."
python3 - <<PYEOF
from nfstream import NFStreamer

df = NFStreamer(
    source="$PCAP_DIR/$NORMAL_PCAP",
    statistical_analysis=True
).to_pandas()

df.to_csv("$DATA_DIR/normal_flows.csv", index=False)
print(f"[+] Done: {len(df)} flows, {df.shape[1]} features")
PYEOF

echo "[*] Extracting attack traffic flows..."
python3 - <<PYEOF
from nfstream import NFStreamer

df = NFStreamer(
    source="$PCAP_DIR/$ATTACK_PCAP",
    statistical_analysis=True
).to_pandas()

df.to_csv("$DATA_DIR/attack_flows.csv", index=False)
print(f"[+] Done: {len(df)} flows, {df.shape[1]} features")
PYEOF

echo "[+] Both extractions complete!"
ls -lh $DATA_DIR/*.csv
