#!/bin/bash
# Copyright 2026 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

cd "$(dirname "$0")"

if [ -z "${GEMINI_API_KEY:-}" ]; then
    echo "[-] Set GEMINI_API_KEY first:"
    echo "    export GEMINI_API_KEY=\"your-key\""
    exit 1
fi

if ! command -v uv &> /dev/null; then
    echo "[-] uv is required. Install from https://docs.astral.sh/uv/"
    exit 1
fi

if [ ! -d ".venv" ]; then
    echo "[+] Creating virtual environment..."
    uv venv
fi

uv pip install -q -r requirements.txt

echo "[+] Running agent: Find the latest blog post from philipp schmid and summarize it."
uv run python agent.py "Find the latest blog post from philipp schmid and summarize it."
