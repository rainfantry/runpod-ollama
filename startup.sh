#!/bin/bash

# =============================================================================
# RunPod Pentest Pod - Startup Script
# GPU-accelerated pentesting environment with Ollama AI + web terminal
# Target: Ubuntu 22.04 | NVIDIA RTX 5090 (32GB VRAM)
# =============================================================================

set -e

echo "============================================"
echo " RunPod Pentest Pod - Initializing..."
echo "============================================"

# ---- System dependencies ----------------------------------------------------
apt-get update -qq
apt-get install -y -qq \
    nmap nikto hydra john hashcat sqlmap gobuster dirb whatweb \
    curl wget git python3 python3-pip python3-venv net-tools \
    libcurl4-openssl-dev libssl-dev > /dev/null 2>&1
echo "[+] System packages ready"

# ---- Metasploit Framework ----------------------------------------------------
if ! command -v msfconsole &>/dev/null; then
    echo "[*] Installing Metasploit Framework..."
    curl -fsSL https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > /tmp/msfinstall
    chmod +x /tmp/msfinstall && /tmp/msfinstall
fi
echo "[+] Metasploit ready"

# ---- httpx -------------------------------------------------------------------
if ! command -v httpx &>/dev/null; then
    echo "[*] Installing httpx..."
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest 2>/dev/null || \
        pip3 install httpx -q
fi
echo "[+] httpx ready"

# ---- SecLists ----------------------------------------------------------------
if [ ! -d "/root/SecLists" ]; then
    echo "[*] Cloning SecLists..."
    git clone --depth 1 https://github.com/danielmiessler/SecLists.git /root/SecLists
fi
echo "[+] SecLists ready"

# ---- enum4linux-ng -----------------------------------------------------------
if [ ! -d "/root/enum4linux-ng" ]; then
    echo "[*] Cloning enum4linux-ng..."
    git clone --depth 1 https://github.com/cddmp/enum4linux-ng.git /root/enum4linux-ng
fi
echo "[+] enum4linux-ng ready"

# ---- ExploitDB + searchsploit ------------------------------------------------
if [ ! -d "/root/exploitdb" ]; then
    echo "[*] Cloning ExploitDB..."
    git clone --depth 1 https://gitlab.com/exploit-database/exploitdb.git /root/exploitdb
fi
if ! command -v searchsploit &>/dev/null; then
    ln -sf /root/exploitdb/searchsploit /usr/local/bin/searchsploit
fi
echo "[+] ExploitDB + searchsploit ready"

# ---- Wifite2 -----------------------------------------------------------------
if [ ! -d "/root/wifite2" ]; then
    echo "[*] Cloning Wifite2..."
    git clone --depth 1 https://github.com/derv82/wifite2.git /root/wifite2
fi
echo "[+] Wifite2 ready"

# ---- Python pentest venv -----------------------------------------------------
if [ ! -d "/root/pentest-venv" ]; then
    echo "[*] Setting up Python pentest venv..."
    python3 -m venv /root/pentest-venv
    source /root/pentest-venv/bin/activate
    pip install -q wfuzz pycurl
    deactivate
fi
echo "[+] Python pentest venv ready"

# ---- Ollama (AI) -------------------------------------------------------------
if ! command -v ollama &>/dev/null; then
    echo "[*] Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
fi

export OLLAMA_HOST="0.0.0.0:11434"
ollama serve &
OLLAMA_PID=$!

echo "[*] Waiting for Ollama server..."
for i in $(seq 1 30); do
    if curl -sf http://localhost:11434 &>/dev/null; then
        echo "[+] Ollama running on port 11434"
        break
    fi
    sleep 1
done

# Pull default models if not present
ollama pull llama3.1:8b 2>/dev/null &
ollama pull mistral 2>/dev/null &
echo "[+] Ollama models pulling in background"

# ---- GoTTY (Web Terminal) ----------------------------------------------------
if ! command -v gotty &>/dev/null; then
    echo "[*] Installing GoTTY..."
    apt-get install -y -qq gotty > /dev/null 2>&1
fi

GOTTY_SECRET=$(cat /root/gotty.hash 2>/dev/null || head -c 32 /dev/urandom | base64 | tr -d '/+=' | head -c 32)
if [ ! -f /root/gotty.hash ]; then
    echo "$GOTTY_SECRET" > /root/gotty.hash
fi

gotty --port 19123 --permit-write --path "/$GOTTY_SECRET/" env TERM=xterm bash &
GOTTY_PID=$!
echo "[+] GoTTY web terminal on port 19123 (secret path: /$GOTTY_SECRET/)"

# ---- Summary -----------------------------------------------------------------
echo ""
echo "============================================"
echo " Pod Ready!"
echo "============================================"
echo " Ollama API  : http://0.0.0.0:11434"
echo " GoTTY Term  : http://0.0.0.0:19123/${GOTTY_SECRET}/"
echo " GPU         : $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo 'N/A')"
echo " Models      : llama3.1:8b, mistral"
echo "============================================"
echo ""

# Keep container alive
wait $OLLAMA_PID $GOTTY_PID
