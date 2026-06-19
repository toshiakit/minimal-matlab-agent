# Minimal MATLAB Agent

This is a minimal MATLAB coding-agent prototype built with MATLAB AI Agent SDK and Ollama.

The SDK owns the LLM client, message history, and agentic tool-calling loop. This project keeps a small stdio MCP bridge so the agent can use MATLAB MCP Server tools from SDK-local wrapper tools.

## Disclaimer

This is a personal, exploratory project. It is intended as a learning example for understanding agentic AI workflows in MATLAB, not as recommended architecture or production guidance.

The prototype uses MATLAB MCP Server from within MATLAB through a small Python stdio bridge. This is not an architecture recommended for practical systems: using MATLAB to call MATLAB code through MCP adds unnecessary complexity and overhead.

The goal is to make agentic workflows more transparent for MATLAB users who want to understand how a coding-agent loop can be assembled from familiar MATLAB pieces, especially in local or privacy-conscious workflows.

## What Are AI Agents?

> "Agents are just LLM + loop + tools."

AI agents act on behalf of users, rather than just provide answers. The key difference from basic AI chatbots is that AI agents have access to tools.

An AI agent runs in a loop, known as an agentic loop. The model decides the next step, the loop carries it out, and tools let it inspect files, run code, call MATLAB, or ask the user for input. The human user sets the boundaries: which tools to enable, how many steps are allowed, and which actions need approval.

In this project, `agent.m` reads user prompts from the command line, then hands each prompt to the SDK:

```matlab
response = run(bot, prompt);
```

The SDK manages the internal model, tool call, tool result, and follow-up loop.

## Requirements

- MATLAB R2022b or later. This prototype has been tested with MATLAB R2026a.
- MATLAB AI Agent SDK
- Ollama running locally or available through a remote Ollama-compatible endpoint
- MATLAB MCP Server
- Python available from MATLAB, used by `mcp/mcp_stdio.py` to manage stdio communication with the MCP server. Use a Python version supported by your MATLAB release; no extra Python packages are required.

## Install Dependencies

1. Install [MATLAB](https://www.mathworks.com/downloads/) R2022b or later.

2. Install the [MATLAB AI Agent SDK](https://github.com/matlab/matlab-ai-agent-sdk).

   Follow the SDK repository's installation instructions. Before running this project, make sure the SDK is on the MATLAB path and that this command returns `8`:

   ```matlab
   exist("aisdk.AIAgent", "class")
   ```

3. Install the [MATLAB MCP Server](https://www.mathworks.com/products/matlab-mcp-server.html).

   Install the server from the MATLAB MCP Server project or through the [MATLAB Agentic Toolkit](https://www.mathworks.com/products/matlab-agentic-toolkit.html) setup flow. This project expects the `matlab-mcp-server` executable to be either:

   - In the standard toolkit location: `~/.matlab/agentic-toolkits/bin/`
   - Available on `PATH`

   On Windows, the executable is named `matlab-mcp-server.exe`.

   Verify the server is available:

   ```bash
   matlab-mcp-server --version
   ```

   If the executable is not on `PATH`, place it in the standard toolkit location:

   ```text
   ~/.matlab/agentic-toolkits/bin/matlab-mcp-server
   ```

   Then verify it with the full path:

   ```bash
   ~/.matlab/agentic-toolkits/bin/matlab-mcp-server --version
   ```

4. Install this project.

   Clone this repository or download it as a ZIP file, then open the project folder in MATLAB:

   ```bash
   git clone https://github.com/toshiakit/minimal-matlab-agent.git
   cd minimal-matlab-agent
   ```

5. Check MATLAB's Python configuration.

   ```matlab
   pyenv
   ```

   If MATLAB cannot find Python, configure it before launching the agent:

   ```matlab
   pyenv(Version="path/to/python")
   ```

6. Install [Ollama](https://ollama.com/) and pull a model.

   This project defaults to `qwen3:8b`, but any Ollama-compatible chat model can be configured in `config.json`.

   ```bash
   ollama pull qwen3:8b
   ollama serve
   ```

   Choose an instruction-tuned chat or coding model that supports tool-calling-style workflows. Larger models generally follow multi-step coding instructions better but need more memory and take longer to respond. Avoid embedding models, such as `nomic-embed-text` or `qwen3-embedding`, because they are for vector search rather than chat.

   Good starting points:

   - Local laptop or limited GPU memory: `qwen3:8b`
   - Remote workstation or larger GPU: `qwen3.6:35b`
   - Large shared model server: `gpt-oss:120b` or a long-context variant, if available

## Configure

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

When the agent starts, the MATLAB MCP Server opens a separate MATLAB session for MCP-backed tools. With the current configuration, that session uses desktop display mode, so a new MATLAB desktop window may appear.

```matlab
agent
```

Override model or endpoint:

```matlab
agent(Model="qwen3.6:35b", Endpoint="http://your-ollama-host:11434")
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

These MCP-backed tools use the local stdio bridge in `mcp/`. The SDK's direct MCP tool wrapper expects an HTTP MCP client, so this bridge remains part of the project for stdio-based MATLAB MCP Server integration.

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

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
