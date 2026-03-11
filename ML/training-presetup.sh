#!/usr/bin/env bash
set -e

# ===== Settings you can tweak =====
PROJECT_ROOT="$HOME/projects/nids-ad"
PYTHON_BIN="python3"
VENV_NAME="venv"
# ================================
echo "[*] Making the folders..."
mkdir -p $HOME/projects/nids-ad

echo "[*] Updating system packages..."
sudo apt update
sudo apt upgrade -y

echo "[*] Installing core system tools..."
sudo apt install -y \
  python3 python3-venv python3-pip \
  git build-essential \
  wget curl \
  htop tmux unzip

echo "[*] Installing network/pcap tools (tshark, wireshark-common, zeek)..."
sudo apt install -y \
  tshark \
  wireshark-common \
  zeek

echo "[*] Creating project directory at: $PROJECT_ROOT"
mkdir -p "$PROJECT_ROOT"
cd "$PROJECT_ROOT"

echo "[*] Creating Python virtual environment: $VENV_NAME"
$PYTHON_BIN -m venv "$VENV_NAME"

echo "[*] Activating virtual environment and upgrading pip..."
# shellcheck disable=SC1090
source "$VENV_NAME/bin/activate"
pip install --upgrade pip

echo "[*] Installing core Python ML and data packages..."
pip install \
  numpy \
  pandas \
  scikit-learn \
  imbalanced-learn \
  matplotlib \
  seaborn \
  jupyterlab \
  pyyaml

echo "[*] Installing optional packages for packet/flow handling..."
pip install \
  pyshark \
  scapy

echo "[*] (Optional) Installing XGBoost if you want to compare later..."
pip install xgboost || echo "[!] xgboost install failed (can be installed later if needed)."

echo "[*] Creating project subdirectories..."
mkdir -p \
  "$PROJECT_ROOT/data/raw/ad_normal" \
  "$PROJECT_ROOT/data/raw/ad_attack" \
  "$PROJECT_ROOT/data/processed" \
  "$PROJECT_ROOT/notebooks" \
  "$PROJECT_ROOT/src" \
  "$PROJECT_ROOT/configs" \
  "$PROJECT_ROOT/tools"
