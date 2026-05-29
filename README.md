# Minimal Agent SDK Prototype

This is a minimal MATLAB coding-agent prototype built with `ai-agent-sdk` and Ollama.

The SDK owns the LLM client, message history, and agentic tool-calling loop. This project keeps a small stdio MCP bridge so the agent can use MATLAB MCP Core Server tools from SDK-local wrapper tools.

## Requirements

- MATLAB R2026a or later
- `ai-agent-sdk` on the MATLAB path, or configured in `config.json`
- Ollama running locally or available through a remote Ollama-compatible endpoint
- MATLAB MCP Core Server executable
- Text Analytics Toolbox, required by the current `ai-agent-sdk` dependency path
- Python available from MATLAB, used by `mcp/mcp_stdio.py` to manage stdio communication with the MCP server. Use a Python version supported by your MATLAB release; no extra Python packages are required.

## Configure

Check MATLAB's Python configuration:

```matlab
pyenv
```

If MATLAB cannot find Python, configure it before launching the agent:

```matlab
pyenv(Version="path/to/python")
```

Edit `config.json`:

```json
{
    "model": "qwen3:8b",
    "ollama_endpoint": "http://127.0.0.1:11434",
    "sdk_path": "",
    "mcp_server_path": "",
    "matlab_root": ""
}
```

Leave `sdk_path` empty if `ai-agent-sdk` is already on the MATLAB path. Leave `matlab_root` empty to use the current MATLAB installation.

## Run

From this directory:

```matlab
agent
```

Override model or endpoint:

```matlab
agent(Model="qwen3-coder:30b-100k", Endpoint="http://your-ollama-host:11434")
```

Run one prompt and return without entering the REPL:

```matlab
agent(Prompt="List files in the current directory.")
```

Override local setup paths without editing `config.json`:

```matlab
agent( ...
    Endpoint="http://your-ollama-host:11434", ...
    Model="qwen3-coder:30b-100k", ...
    McpServerPath="path/to/matlab-mcp-core-server", ...
    SdkPath="path/to/ai-agent-sdk")
```

Type `quit` or `exit` to leave the session.

## Tools

Local tools:

- `read_file`
- `write_file`
- `list_files`
- `ask_user`

MCP-backed MATLAB tools:

- `evaluate_matlab_code`
- `detect_matlab_toolboxes`
- `check_matlab_code`
- `run_matlab_file`
- `run_matlab_test_file`

## Project Layout

```text
agent.m              Main SDK/Ollama REPL entry point
config.json          Runtime configuration
get_tools.m          SDK tool registration
load_config.m        Config loader
get_system_prompt.m  Agent instructions
tools/               Local tools and MCP wrapper tools
mcp/                 Stdio MCP client and Python subprocess shim
```
