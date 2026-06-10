# Minimal Agent SDK Prototype

This is a minimal MATLAB coding-agent prototype built with MATLAB AI Agent SDK and Ollama.

The SDK owns the LLM client, message history, and agentic tool-calling loop. This project keeps a small stdio MCP bridge so the agent can use MATLAB MCP Core Server tools from SDK-local wrapper tools.

## Disclaimer

This is a personal, exploratory project. It is intended as a learning example for understanding agentic AI workflows in MATLAB, not as recommended architecture or production guidance.

The prototype uses MATLAB MCP Core Server from within MATLAB through a small Python stdio bridge. This is not an architecture recommended for practical systems: using MATLAB to call MATLAB code through MCP adds unnecessary complexity and overhead.

The goal is to make agentic workflows more transparent for MATLAB users who want to understand how a coding-agent loop can be assembled from familiar MATLAB pieces, especially in local or privacy-conscious workflows.

## Requirements

- MATLAB R2026a or later
- MATLAB AI Agent SDK installed in the standard Add-Ons location and on the MATLAB path
- Ollama running locally or available through a remote Ollama-compatible endpoint
- MATLAB MCP Core Server installed in the standard agentic-toolkits location
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
    "max_tokens": 8192,
    "timeout": 600,
    "max_iterations": 10,
    "verbose": false
}
```

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

These MCP-backed tools use the local stdio bridge in `mcp/`. The SDK's direct MCP tool wrapper expects an HTTP MCP client, so this bridge remains part of the project for stdio-based MATLAB MCP Core Server integration.

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
