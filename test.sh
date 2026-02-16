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

assert_non_empty() {
	local name="$1"
	local value="${!name:-}"
	if [ -z "$value" ]; then
		echo "Expected $name to be set"
		exit 1
	fi
}

TEST_BASE_URL="https://litellm.example.com"
TEST_API_KEY="sk-test-key"
TEST_MODEL="gemini-2.5-pro"

echo "- Verifying claude provider config"
export ANTHROPIC_BASE_URL="${TEST_BASE_URL}"
export ANTHROPIC_AUTH_TOKEN="${TEST_API_KEY}"
export ANTHROPIC_MODEL="${TEST_MODEL}"
for var_name in ANTHROPIC_BASE_URL ANTHROPIC_AUTH_TOKEN ANTHROPIC_MODEL; do
	assert_non_empty "$var_name"
done
claude --version >/dev/null

echo "- Verifying codex provider config"
export LITELLM_API_BASE="${TEST_BASE_URL}"
export LITELLM_API_KEY="${TEST_API_KEY}"
for var_name in LITELLM_API_BASE LITELLM_API_KEY; do
	assert_non_empty "$var_name"
done
mkdir -p "${HOME}/.codex"
cat >"${HOME}/.codex/config.toml" <<EOF
model = "${TEST_MODEL}"
model_provider = "litellm"

[model_providers.litellm]
name = "LiteLLM"
base_url = "${LITELLM_API_BASE}"
env_key = "LITELLM_API_KEY"
wire_api = "responses"
EOF
grep -q "${TEST_MODEL}" "${HOME}/.codex/config.toml"
codex --version >/dev/null

echo "- Verifying gemini provider config"
export GOOGLE_GEMINI_BASE_URL="${TEST_BASE_URL}"
export GEMINI_API_KEY="${TEST_API_KEY}"
export GEMINI_MODEL="${TEST_MODEL}"
for var_name in GOOGLE_GEMINI_BASE_URL GEMINI_API_KEY GEMINI_MODEL; do
	assert_non_empty "$var_name"
done
gemini --version >/dev/null

echo "- Verifying opencode provider config"
export OPENAI_BASE_URL="${TEST_BASE_URL}"
export OPENAI_API_KEY="${TEST_API_KEY}"
export OPENAI_MODEL="${TEST_MODEL}"
for var_name in OPENAI_BASE_URL OPENAI_API_KEY OPENAI_MODEL; do
	assert_non_empty "$var_name"
done
opencode --version >/dev/null

echo "- Verifying qwen provider config"
export OPENAI_BASE_URL="${TEST_BASE_URL}"
export OPENAI_API_KEY="${TEST_API_KEY}"
export OPENAI_MODEL="${TEST_MODEL}
for var_name in OPENAI_BASE_URL OPENAI_API_KEY OPENAI_MODEL; do
	assert_non_empty "$var_name"
done
qwen --version >/dev/null

echo "- Verifying configured CLI path env vars"
for path_var in CLAUDE_PATH CODEX_PATH GEMINI_PATH OPENCODE_PATH QWEN_PATH; do
	value="${!path_var}"
	[ -n "$value" ]
	[ -x "$value" ]
done

echo "All Docker smoke tests passed."
'

echo "Test completed successfully."
