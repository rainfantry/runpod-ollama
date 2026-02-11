# RunPod Pentest Pod

GPU-accelerated penetration testing environment with AI-assisted recon via Ollama, running on RunPod.

## Environment

| Component | Detail |
|-----------|--------|
| OS | Ubuntu 22.04.5 LTS |
| GPU | NVIDIA RTX 5090 (32 GB VRAM) |
| AI Backend | Ollama with llama3.1:8b, mistral |
| Web Terminal | GoTTY (browser-based shell) |

## Services

| Service | Port | Description |
|---------|------|-------------|
| Ollama API | `11434` | LLM inference server, bound to `0.0.0.0` |
| GoTTY | `19123` | Web terminal with secret URL path for auth |

Both ports must be exposed in your RunPod template network settings.

## Pre-installed Tools

### Reconnaissance & Scanning
- **nmap** - Network discovery and port scanning
- **nikto** - Web server vulnerability scanner
- **whatweb** - Web technology fingerprinting
- **httpx** - Fast HTTP probing
- **enum4linux-ng** - SMB/Windows enumeration (`/root/enum4linux-ng/`)

### Exploitation
- **Metasploit Framework** (`msfconsole`) - Exploit development and delivery
- **sqlmap** - Automated SQL injection
- **searchsploit** - Offline ExploitDB search (`/root/exploitdb/`)
- **hydra** - Network login brute-forcer

### Web & Directory Fuzzing
- **gobuster** - Directory/DNS brute-forcing
- **dirb** - Web content scanner
- **wfuzz** - Web fuzzer (in `/root/pentest-venv/`)

### Password Cracking (GPU-accelerated)
- **hashcat** - GPU-powered hash cracking (uses RTX 5090)
- **john** (John the Ripper) - CPU/GPU password cracker

### Wordlists & Databases
- **SecLists** (`/root/SecLists/`) - Passwords, usernames, fuzzing payloads, web shells
- **ExploitDB** (`/root/exploitdb/`) - Public exploits archive

### Wireless
- **Wifite2** (`/root/wifite2/`) - Automated wireless auditing

### AI / LLM
- **Ollama** - Local LLM inference on GPU
  - `llama3.1:8b` - General purpose assistant
  - `mistral` - Fast reasoning model

## Usage

### Start the pod

The startup script auto-installs all dependencies and launches services:

```bash
chmod +x startup.sh
./startup.sh
```

Set `/root/startup.sh` as the container start command in your RunPod template.

### Ollama AI queries

```bash
# Interactive chat
ollama run llama3.1:8b

# API call
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.1:8b",
  "prompt": "Explain the OWASP top 10 vulnerabilities",
  "stream": false
}'

# Pull additional models
ollama pull codellama
ollama pull phi3
```

### GPU hash cracking

```bash
# Crack NTLM hashes with RTX 5090
hashcat -m 1000 hashes.txt /root/SecLists/Passwords/Leaked-Databases/rockyou.txt

# Benchmark GPU performance
hashcat -b
```

### Web terminal access

GoTTY provides browser-based shell access. The URL includes a secret path for basic auth:

```
http://<pod-ip>:19123/<secret>/
```

The secret is stored in `/root/gotty.hash`.

### Common workflows

```bash
# Recon scan
nmap -sC -sV -oA scan_results target.com

# Web enum
gobuster dir -u http://target.com -w /root/SecLists/Discovery/Web-Content/directory-list-2.3-medium.txt

# SQL injection test
sqlmap -u "http://target.com/page?id=1" --batch

# Exploit search
searchsploit apache 2.4

# SMB enum
python3 /root/enum4linux-ng/enum4linux-ng.py -A target.com
```

## File Structure

```
/root/
├── startup.sh          # Auto-install & launch script
├── gotty.hash          # GoTTY web terminal secret path
├── gotty.log           # GoTTY session log
├── SecLists/           # Wordlists & payloads
├── exploitdb/          # ExploitDB + searchsploit
├── enum4linux-ng/      # SMB enumeration tool
├── wifite2/            # Wireless audit tool
└── pentest-venv/       # Python venv (wfuzz, etc.)
```

## Disclaimer

This environment is intended for **authorized security testing, CTF competitions, and educational purposes only**. Always obtain proper authorization before testing systems you do not own.
