# codex.agent

Docker environment for the Codex Gerrit plugin agents. This image bundles all supported AI agents into a single container, ready to be used by `codex.serve`.

## Included agents

- **Codex CLI** (`codex`): Installed via `@openai/codex`.
- **OpenCode** (`opencode`): Installed via `opencode-ai`.
- **Qwen Code** (`qwen`): Installed via `@qwen-code/qwen-code`.

## Requirements

- Docker installed.

## Build

Build the image from the `codex.agent` directory:

```bash
./build.sh
```

## Test

Run the Docker smoke test from the `codex.agent` directory:

```bash
./test.sh
```

The test script builds a temporary image (`codex-agent:test`) and verifies:

- Base image is Ubuntu.
- All required agent binaries are available and return `--version`.
- Per-agent provider settings are validated with explicit test values for base URL, API key, and model:
  - `codex`: `LITELLM_BASE_URL`, `LITELLM_API_KEY`, and `~/.codex/config.toml` model/provider config
	- `opencode`: `OPENAI_BASE_URL`, `OPENAI_API_KEY`, `OPENAI_MODEL`
	- `qwen`: `OPENAI_BASE_URL`, `OPENAI_API_KEY`, `OPENAI_MODEL`
- `CODEX_PATH`, `OPENCODE_PATH`, and `QWEN_PATH` are set to executable paths.

## Usage

This image is designed to work with `codex.serve`.

1.  Build the image as shown above.
2.  Configure `codex.serve` to use this image by setting the `CODEX_AGENT_IMAGE` environment variable.

```bash
export CODEX_AGENT_IMAGE=craftslab/codex-agent:latest
python codex.serve/codex_serve.py
```

`codex.serve` will then spin up this container for every agent request, passing necessary environment variables (like API keys) and streaming the output back to the plugin.

### Manual Usage

You can also run the container interactively for testing:

```bash
docker run -it --rm craftslab/codex-agent:latest bash
codex --version
opencode --version
qwen --version
```

### Configuration via Environment Variables

The image supports automatic configuration of the agents using a standard set of environment variables. This is handled by the entrypoint script.

- `AGENT_PROVIDER_NAME`: The name of the agent to configure (`codex`, `opencode`, `qwen`).
- `LITELLM_BASE_URL`: The base URL for the API provider.
- `LITELLM_API_KEY`: The API key for the provider.
- `LITELLM_MODEL`: The model name to use.

Example:

```bash
docker run --rm \
  -e AGENT_PROVIDER_NAME=codex \
  -e LITELLM_BASE_URL="https://your-litellm-endpoint" \
  -e LITELLM_API_KEY="sk-..." \
  -e LITELLM_MODEL="gpt-5" \
  craftslab/codex-agent:latest \
  codex "Hello, world!"
```
