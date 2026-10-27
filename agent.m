function agent(options)
%AGENT Minimal MATLAB coding agent prototype using MATLAB AI Agent SDK and Ollama.
%   agent
%   agent(Model="qwen3-coder:30b-100k")
%   agent(Endpoint="http://your-ollama-host:11434")
%   agent(Prompt="List files in the current directory.")

    arguments
        options.Model (1,1) string = ""
        options.Endpoint (1,1) string = ""
        options.Prompt (1,1) string = ""
        options.Verbose (1,1) logical = false
    end

    projectDir = fileparts(mfilename("fullpath"));
    originalPath = path;
    pathCleanup = onCleanup(@() path(originalPath));
    addpath(projectDir);
    addpath(fullfile(projectDir, "tools"));

    run_agent(options, projectDir);
end

function run_agent(options, projectDir)
    cfg = load_config();
    assert_sdk_available();

    model = options.Model;
    if model == ""
        model = string(cfg.model);
    end

    endpoint = options.Endpoint;
    if endpoint == ""
        endpoint = string(cfg.ollama_endpoint);
    end

    client = aisdk.LLMClient("ollama", model, ...
        MaxNumTokens=cfg.max_tokens, ...
        TimeOut=cfg.timeout, ...
        BaseURL=endpoint);

    mcpClient = connect_mcp(projectDir);
    cleanup = onCleanup(@() delete(mcpClient));
    tools = get_tools(mcpClient);

    if logical(cfg.verbose) || options.Verbose
        displayMode = "detailed";
    else
        displayMode = "off";
    end

    bot = aisdk.AIAgent(client, ...
        SystemPrompt=get_system_prompt() + newline + ...
            "Project root: " + string(projectDir) + newline + ...
            "Use this absolute project root for project_path in MCP calls. " + ...
            "Use absolute script_path values for MCP file and test tools.", ...
        Tools=tools, ...
        MaxIterations=cfg.max_iterations, ...
        DisplayMode=displayMode);

    disp("Minimal MATLAB Agent - Ollama (type ""quit"" to exit)");
    disp("====================================================");

    if options.Prompt ~= ""
        run_once(bot, options.Prompt);
        return
    end

    while true
        userInput = string(input("You>> ", "s"));
        userInput = strtrim(userInput);
        if strlength(userInput) == 0
            continue
        end

        if ismember(lower(userInput), ["quit", "exit"])
            disp("Goodbye!");
            break
        end

        try
            run_once(bot, userInput);
        catch ME
            disp("Agent error: " + ME.message);
        end
    end
end

function assert_sdk_available()
    if ~exist("aisdk.AIAgent", "class")
        error("agent:sdkNotFound", ...
            "MATLAB AI Agent SDK is not on the MATLAB path. Install it in the standard Add-Ons location or add it to the MATLAB path.");
    end
end

function run_once(bot, prompt)
    response = run(bot, prompt);
    if isstring(response) || ischar(response)
        disp(newline + "Agent: " + string(response) + newline);
    else
        disp(newline + "Agent: " + jsonencode(response) + newline);
    end
end
