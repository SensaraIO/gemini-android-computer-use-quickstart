# Gemini Android Computer Use Demo

This repository contains a reference implementation for controlling an Android emulator using the **Gemini 3.5 Flash** Computer Use API (`mobile` environment) via the Google GenAI SDK.

## Overview

The agent operates in a continuous loop:
1. It captures a screenshot of the virtual device using ADB.
2. It sends the screenshot along with the user's task to Gemini 3.5 Flash.
3. The model returns structured tool commands (such as `click`, `type`, `long_press`, `drag_and_drop`, `press_key`, `go_back`, `wait`, `list_apps`, `open_app`, `take_screenshot`).
4. The client executing script maps the normalized coordinates (0-999) to the actual physical resolution of the screen and executes the action via ADB.
5. The loop repeats until the task is complete.

## Directory Structure

*   `agent.py`: The main agent script orchestrating the interaction loop.
*   `setup_emulator.sh`: Idempotent shell script to configure and create the Android virtual device (`AI_Agent_Phone`) on macOS.
*   `requirements.txt`: Python package dependencies.
*   `run.sh`: Convenient entrypoint script to create virtualenv, install dependencies, and run the agent.

## Setup Instructions

### Prerequisites

Ensure you have the following installed on your Mac:
*   [Homebrew](https://brew.sh/)
*   [uv](https://docs.astral.sh/uv/) (highly recommended for Python dependency management)

### 1. Configure the Virtual Device

Run the setup script to install the Android CLI tools, system images, and create the `AI_Agent_Phone` emulator instance:

```bash
chmod +x setup_emulator.sh
./setup_emulator.sh
```

### 2. Set Up API Key

Retrieve your API key from Google AI Studio and export it:

```bash
export GEMINI_API_KEY="your-api-key-here"
```

### 3. Run the Agent

You can launch the agent by executing `run.sh`:

```bash
chmod +x run.sh
./run.sh
```

By default, the script runs the task: *"Find the latest blog post from philipp schmid and summarize it."*
Alternatively, you can run the agent manually:

```bash
python agent.py "Open Settings and enable dark mode"
```

---

## Disclaimer

*This is not an officially supported Google product.*
