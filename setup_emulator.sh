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

# Idempotent setup for Android Emulator on macOS. Safe to run multiple times.

set -e

# ── Config ──────────────────────────────────────────────────
AVD_NAME="AI_Agent_Phone"
ANDROID_API="35"

ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    SYS_IMAGE="system-images;android-${ANDROID_API};google_apis;arm64-v8a"
    ANDROID_HOME_DEFAULT="/opt/homebrew/share/android-commandlinetools"
    echo "[+] Detected Apple Silicon (ARM64)"
else
    SYS_IMAGE="system-images;android-${ANDROID_API};google_apis;x86_64"
    ANDROID_HOME_DEFAULT="/usr/local/share/android-commandlinetools"
    echo "[+] Detected Intel (x86_64)"
fi

# ── 1. Java ─────────────────────────────────────────────────
if java -version &> /dev/null 2>&1; then
    echo "[✓] Java already installed."
else
    echo "[+] Installing Java (Temurin)..."
    brew install --cask temurin
fi

# ── 2. Android Command Line Tools ──────────────────────────
if [ -d "$ANDROID_HOME_DEFAULT" ]; then
    echo "[✓] Android Command Line Tools already installed."
else
    echo "[+] Installing Android Command Line Tools..."
    brew install --cask android-commandlinetools
fi

# ── 3. Set PATH for this session ────────────────────────────
export ANDROID_HOME="$ANDROID_HOME_DEFAULT"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/emulator:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"

if ! command -v sdkmanager &> /dev/null; then
    echo "[-] sdkmanager not found at $ANDROID_HOME/cmdline-tools/latest/bin"
    exit 1
fi

# ── 4. Accept licenses (quiet if already accepted) ─────────
if yes | sdkmanager --licenses > /dev/null 2>&1; then
    echo "[✓] SDK licenses accepted."
fi

# ── 5. Install SDK components (skips already-installed) ─────
PACKAGES=("platform-tools" "emulator" "platforms;android-${ANDROID_API}" "$SYS_IMAGE")
INSTALLED=$(sdkmanager --list_installed 2>/dev/null || sdkmanager --list 2>/dev/null | sed -n '/Installed/,/Available/p')

NEEDED=()
for pkg in "${PACKAGES[@]}"; do
    if echo "$INSTALLED" | grep -q "$pkg"; then
        echo "[✓] $pkg already installed."
    else
        NEEDED+=("$pkg")
    fi
done

if [ ${#NEEDED[@]} -gt 0 ]; then
    echo "[+] Installing: ${NEEDED[*]}"
    sdkmanager "${NEEDED[@]}"
else
    echo "[✓] All SDK components already installed."
fi

# ── 6. Create AVD (skip if exists) ──────────────────────────
if emulator -list-avds 2>/dev/null | grep -q "^${AVD_NAME}$"; then
    echo "[✓] AVD '$AVD_NAME' already exists."
else
    echo "[+] Creating AVD '$AVD_NAME'..."
    echo "no" | avdmanager create avd -n "$AVD_NAME" -k "$SYS_IMAGE" --force
    echo "[✓] AVD '$AVD_NAME' created."
fi

# ── Done ────────────────────────────────────────────────────
echo ""
echo "===================================================="
echo "[✓] Setup complete!"
echo "===================================================="
echo ""
echo "Add these to your ~/.zshrc (or ~/.bash_profile):"
echo ""
echo "  export ANDROID_HOME=\"$ANDROID_HOME\""
echo "  export PATH=\"\$ANDROID_HOME/cmdline-tools/latest/bin:\$PATH\""
echo "  export PATH=\"\$ANDROID_HOME/emulator:\$PATH\""
echo "  export PATH=\"\$ANDROID_HOME/platform-tools:\$PATH\""
echo ""
echo "Then:"
echo "  source ~/.zshrc"
echo "  emulator -avd $AVD_NAME"
echo "===================================================="
