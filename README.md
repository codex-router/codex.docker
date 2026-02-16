# codex.docker

Docker environment for the Codex Gerrit plugin CLIs. This image bundles all supported AI CLIs into a single container, ready to be used by `codex.serve`.

## Included CLIs

- **Claude Code** (`claude`): Installed via `@anthropic-ai/claude-code`.
- **Codex CLI** (`codex`): Installed via `@openai/codex`.
- **Gemini CLI** (`gemini`): Installed via `@google/gemini-cli`.
- **OpenCode** (`opencode`): Installed via `opencode-ai`.
- **Qwen Code** (`qwen`): Installed via `@qwen-code/qwen-code`.

## Requirements

- Docker installed.

## Build

Build the image from the `codex.docker` directory:

```bash
./build.sh
```

## Test

Run the Docker smoke test from the `codex.docker` directory:

```bash
./test.sh
```

The test script builds a temporary image (`codex-cli-env:test`) and verifies:

- Base image is Ubuntu.
- All required CLI binaries are available and return `--version`.
- `CLAUDE_PATH`, `CODEX_PATH`, `GEMINI_PATH`, `OPENCODE_PATH`, and `QWEN_PATH` are set to executable paths.

## Usage

This image is designed to work with `codex.serve`.

1.  Build the image as shown above.
2.  Configure `codex.serve` to use this image by setting the `CODEX_DOCKER_IMAGE` environment variable.

```bash
export CODEX_DOCKER_IMAGE=craftslab/codex-cli-env:latest
python codex.serve/codex_serve.py
```

`codex.serve` will then spin up this container for every CLI request, passing necessary environment variables (like API keys) and streaming the output back to the plugin.

### Manual Usage

You can also run the container interactively for testing:

```bash
docker run -it --rm craftslab/codex-cli-env:latest bash
claude --version
codex --version
gemini --version
opencode --version
qwen --version
```
