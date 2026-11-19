# Basic Ubuntu setup: Ollama with Qwen, Open WebUI, and VS Code

This guide covers the basic setup steps for running local AI tools on Ubuntu, plus the commands to start and stop each service.

## 1) Basic system setup

Run these once on your Ubuntu machine:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl ca-certificates git docker.io
sudo systemctl enable --now docker
```

If you plan to use Docker-based Open WebUI, Docker must be running.

---

## 2) Ollama with Qwen

### Install Ollama

```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama --version
```

### Pull a model

A common choice is Qwen:

```bash
ollama pull qwen2.5:7b
```

You can replace `qwen2.5:7b` with another Qwen model name depending on your hardware and preference.

### Start Ollama

```bash
ollama serve
```

If you want it as a system service:

```bash
sudo systemctl enable --now ollama
```

To disable auto-start on boot:
```bash
sudo systemctl disable ollama
```

To manually start Ollama (if disabled):
```bash
sudo systemctl start ollama
```

To check the status of Ollama service:
```bash
sudo systemctl status ollama
```

### Stop Ollama

```bash
sudo systemctl stop ollama
```

If it is running directly in a terminal, stop it with Ctrl+C in that terminal.

### Test it

```bash
curl http://localhost:11434
```

---

## 3) Open WebUI (web interface)

Open WebUI gives you a browser-based interface for chatting with local models.

### Install and start

```bash
docker run -d \
  --name open-webui \
  --restart always \
  -p 3000:8080 \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://localhost:11434 \
  ghcr.io/open-webui/open-webui:main
```

Then open:

```text
http://localhost:3000
```

### First-time setup

On the first visit, Open WebUI may ask you to create an admin account and set a password. If it does, use a strong password and remember it because it is used to log in to the web interface.

After login:

1. Go to the admin or settings area.
2. Add or confirm your default model provider as Ollama.
3. Set the Ollama base URL to:

```text
http://localhost:11434
```

4. Select a model such as:

```text
qwen2.5:7b
```

You can also create a new workspace or chat session from there and start testing the model.

### Stop Open WebUI

```bash
docker stop open-webui
```

### Start it again later

```bash
docker start open-webui
```

### Remove it completely

```bash
docker stop open-webui
docker rm open-webui
```

### Update Open WebUI

When a new Open WebUI image is available, update it carefully so you do not lose your local chat history or settings.

1. Stop the container:

```bash
docker stop open-webui
```

2. Pull the latest image:

```bash
docker pull ghcr.io/open-webui/open-webui:main
```

3. Remove the old container:

```bash
docker rm open-webui
```

4. Start a fresh container with the same volume and port:

```bash
docker run -d \
  --name open-webui \
  --restart always \
  -p 3000:8080 \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://localhost:11434 \
  ghcr.io/open-webui/open-webui:main
```

This keeps your data in the `open-webui` Docker volume. If you used a different volume name or custom configuration, make sure to keep those settings the same when recreating the container.

---

## 4) Ollama in VS Code

You can use Ollama from VS Code with an extension such as Continue or an Ollama-aware AI extension.

### Setup and Configuration

1. **Install an Ollama-compatible extension**:
   - Install an extension like "Continue" or "Ollama" from the VS Code marketplace
   - Make sure it supports local LLMs and Ollama integration

2. **Configure the Ollama connection**:
   - Open VS Code settings (Ctrl+,)
   - Look for the Ollama extension settings
   - Set the provider to "Ollama"
   - Configure the base URL as:

```text
http://localhost:11434
```

3. **Verify model availability**:
   - After configuring, restart VS Code or reload the window
   - Check that your Ollama models (like qwen2.5:7b) appear in the model selection dropdown
   - If models don't show up, ensure Ollama is running and accessible

### Troubleshooting Common Issues

#### Models not showing up in VS Code
1. Ensure Ollama service is running:
   ```bash
   ollama serve
   ```
2. Check if models are available via command line:
   ```bash
   ollama list
   ```
3. Restart the VS Code extension or reload the window
4. Verify the Ollama base URL in extension settings matches your local setup

#### Confusion with Copilot or other AI services
1. **Disable Copilot integration** in VS Code if you want to exclusively use Ollama:
   - Go to Settings → Extensions → GitHub Copilot
   - Disable the extension or uncheck "Enable Copilot"
2. **Use explicit model selection**: Always explicitly select your local Ollama model from the dropdown when initiating chat or code completion

#### Model Selection Issues
1. When starting a new chat or code completion, ensure you're selecting the correct local model:
   - Look for models with names like `qwen2.5:7b` (or whatever you pulled)
   - Avoid selecting cloud-based models if you want to stay local

### Start VS Code integration

The integration depends on the Ollama server being running:

```bash
ollama serve
```

### Stop VS Code integration

No special VS Code service is required to stop. Just stop Ollama when you are done:

```bash
sudo systemctl stop ollama
```

---

## Quick summary

```bash
# Start everything
ollama serve
# Open WebUI is separate, started with Docker
# VS Code connects to localhost:11434

# Stop everything
sudo systemctl stop ollama
docker stop open-webui
```

## Context Size Configuration

To configure the context size for Ollama models:

1. **View current model settings**:
   ```bash
   ollama show qwen2.5:7b
   ```

2. **Create or modify a model with custom context size**:
   ```bash
   ollama create my-qwen -f ./Modelfile
   ```
   
   Where `Modelfile` contains:
   ```
   FROM qwen2.5:7b
   PARAMETER temperature 0.7
   PARAMETER num_ctx 8192
   ```

3. **Set context size for existing models** (requires model recreation):
   - Stop Ollama service: `sudo systemctl stop ollama`
   - Delete the model: `ollama delete qwen2.5:7b`
   - Recreate with new context size: `ollama create qwen2.5:7b -f ./Modelfile`
   - Start Ollama service: `sudo systemctl start ollama`

## Related

- [Back to the tips and tricks index](../../README.md)
