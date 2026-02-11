# RunPod Ollama Server

Auto-start script for running [Ollama](https://ollama.com) on a RunPod instance.

## What it does

- Automatically installs Ollama if not already present
- Starts the Ollama API server on port `11434`, bound to all interfaces
- Waits for the server to be ready before reporting status
- Keeps the container alive

## Usage

### As RunPod startup script

Set `/root/startup.sh` as your container's start command in the RunPod template.

### Manual

```bash
chmod +x startup.sh
./startup.sh
```

### Pulling a model

Once the server is running:

```bash
ollama pull llama3
ollama run llama3 "Hello!"
```

### API access

```bash
curl http://<pod-ip>:11434/api/generate -d '{
  "model": "llama3",
  "prompt": "Hello!"
}'
```

## Port

| Service | Port  |
|---------|-------|
| Ollama  | 11434 |

Make sure port `11434` is exposed in your RunPod template settings.
