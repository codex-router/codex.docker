#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

IMAGE_TAG="codex-cli-env:test"

echo "[1/2] Building Docker image: ${IMAGE_TAG}"
docker build -t "${IMAGE_TAG}" -f Dockerfile .

echo "[2/2] Running smoke tests in container"
docker run --rm "${IMAGE_TAG}" bash -lc '
set -euo pipefail

echo "- Verifying Ubuntu base image"
if ! grep -qi "^ID=ubuntu" /etc/os-release; then
	echo "Expected Ubuntu base image, but /etc/os-release is:"
	cat /etc/os-release
	exit 1
fi

echo "- Verifying required CLI binaries"
for cmd in claude codex gemini opencode qwen; do
	command -v "$cmd" >/dev/null
	"$cmd" --version >/dev/null
done

echo "- Verifying configured CLI path env vars"
for path_var in CLAUDE_PATH CODEX_PATH GEMINI_PATH OPENCODE_PATH QWEN_PATH; do
	value="${!path_var}"
	[ -n "$value" ]
	[ -x "$value" ]
done

echo "All Docker smoke tests passed."
'

echo "Test completed successfully."
