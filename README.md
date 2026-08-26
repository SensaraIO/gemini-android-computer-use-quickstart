# Gemini Computer Use Agent

This local version adds one Gemini 3.7 Flash CLI for all three Computer Use environments. It can control the Android emulator, the existing Google Chrome profile, or the live macOS desktop.

`gemini-computer.py` has no separate control UI. Browser and desktop modes still require a logged-in graphical macOS session because the model acts from screenshots.

## Setup

Requirements:

* macOS for browser and desktop modes
* `uv`
* `GEMINI_API_KEY`
* Accessibility and Screen Recording permission for the terminal or process that launches desktop and browser runs
* Android SDK and the `AI_Agent_Phone` AVD for mobile mode

Set the API key:

```bash
export GEMINI_API_KEY="your-api-key-here"
```

For mobile mode, create the emulator once:

```bash
chmod +x setup_emulator.sh
./setup_emulator.sh
```

The script uses PEP 723 metadata, so `uv` installs its Python packages automatically.

## Usage

Run one environment flag with a task:

```bash
./gemini-computer.py --mobile "Open Settings and enable dark mode"
./gemini-computer.py --browser "Open the Gemini API docs and find the Computer Use model list"
./gemini-computer.py --desktop "Open TextEdit and create a note titled Weekly Plan"
```

Set the thinking level:

```bash
./gemini-computer.py --desktop --thinking-level high "Organize the open Finder window"
```

Choose another macOS display. Display `0` is the main display:

```bash
./gemini-computer.py --desktop --display 1 "Open Calendar"
```

Check local dependencies and permissions without calling Gemini or controlling the UI:

```bash
./gemini-computer.py --desktop --check
./gemini-computer.py --browser --check
./gemini-computer.py --mobile --check
```

Other useful options:

| Option | Default | Description |
| --- | --- | --- |
| `--model`, `-m` | `gemini-3.7-flash` | Gemini model ID |
| `--thinking-level`, `-t` | `medium` | `minimal`, `low`, `medium`, or `high` |
| `--max-turns` | `100` | Maximum model/action turns |
| `--device-id` | automatic | ADB device for mobile mode |
| `--avd` | `AI_Agent_Phone` | AVD to boot for mobile mode |
| `--display` | `0` | macOS display used for capture and coordinates |
| `--browser-app` | `Google Chrome` | Existing macOS browser application to control |

## Tool behavior

The CLI implements every Gemini 3.x predefined action documented for its selected environment. It does not pass `excluded_predefined_functions`.

Browser mode opens and controls the normal Google Chrome application and its current profile. Desktop mode controls the current macOS session. Neither mode creates a Playwright browser, browser profile, VM, or container.

Prompt-injection detection is explicitly off. The request asks Gemini to disable all seven documented configurable Computer Use policies:

* `financial_transactions`
* `sensitive_data_modification`
* `communication_tool`
* `account_creation`
* `data_modification`
* `user_consent_management`
* `legal_terms_and_agreements`

Google notes that overrides are preferences. The service can still block an action or return `require_confirmation`. The CLI stops on blocked actions and asks for terminal confirmation when the API requires it. Non-interactive runs stop rather than claim a confirmation occurred.

## Original mobile quickstart

`agent.py` remains the original Android-only entry point:

```bash
uv run agent.py "Find the latest blog post from philipp schmid and summarize it."
```
