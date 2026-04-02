#!/bin/bash
# label_and_merge.sh - Updated for NFStream output

DATA_DIR=~/nids_project/data
MASTER="$DATA_DIR/master_dataset.csv"

echo "[*] Adding labels..."
HEADER=$(head -1 "$DATA_DIR/normal_flows.csv")
echo "${HEADER},label" > "$DATA_DIR/normal_labelled.csv"
tail -n +2 "$DATA_DIR/normal_flows.csv" | awk '{print $0",0"}' >> "$DATA_DIR/normal_labelled.csv"

echo "${HEADER},label" > "$DATA_DIR/attack_labelled.csv"
tail -n +2 "$DATA_DIR/attack_flows.csv" | awk '{print $0",1"}' >> "$DATA_DIR/attack_labelled.csv"

echo "[*] Merging into master dataset..."
cat "$DATA_DIR/normal_labelled.csv" > "$MASTER"
tail -n +2 "$DATA_DIR/attack_labelled.csv" >> "$MASTER"

echo "[+] Master dataset created: $MASTER"
echo "[*] Total rows: $(( $(wc -l < "$MASTER") - 1 ))"
echo "[*] Normal flows: $(( $(wc -l < "$DATA_DIR/normal_labelled.csv") - 1 ))"
echo "[*] Attack flows: $(( $(wc -l < "$DATA_DIR/attack_labelled.csv") - 1 ))"