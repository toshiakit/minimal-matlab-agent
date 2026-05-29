function agent(options)
%AGENT Minimal MATLAB coding agent prototype using ai-agent-sdk and Ollama.
%   agent
%   agent(Model="qwen3-coder:30b-100k")
%   agent(Endpoint="http://your-ollama-host:11434")
%   agent(Prompt="List files in the current directory.")

    arguments
        options.Model (1,1) string = ""
        options.Endpoint (1,1) string = ""
        options.SdkPath (1,1) string = ""
        options.McpServerPath (1,1) string = ""
        options.MatlabRoot (1,1) string = ""
        options.Prompt (1,1) string = ""
        options.Verbose (1,1) logical = false
    end

    projectDir = fileparts(mfilename("fullpath"));
    originalPath = path;
    pathCleanup = onCleanup(@() path(originalPath));
    addpath(projectDir);
    addpath(fullfile(projectDir, "tools"));
    addpath(fullfile(projectDir, "mcp"));

    cfg = load_config();
    add_sdk_path(resolve_option(options.SdkPath, cfg, "sdk_path"));

    model = options.Model;
    if model == ""
        model = string(cfg.model);
    end

    endpoint = options.Endpoint;
    if endpoint == ""
        endpoint = string(cfg.ollama_endpoint);
    end

    client = aisdk.llmClient("ollama", model, ...
        MaxNumTokens=cfg.max_tokens, ...
        TimeOut=cfg.timeout, ...
        BaseURL=endpoint);

    mcpServerPath = resolve_option(options.McpServerPath, cfg, "mcp_server_path");
    matlabRoot = resolve_option(options.MatlabRoot, cfg, "matlab_root");
    mcpClient = connect_mcp(mcpServerPath, matlabRoot);
    cleanup = onCleanup(@() disconnect(mcpClient));

    workspace = struct("mcpClient", mcpClient, "projectDir", projectDir);
    tools = get_tools();
    bot = aisdk.aiAgent(client, get_system_prompt(), tools, ...
        Workspace=workspace, ...
        MaxIterations=cfg.max_iterations, ...
        Verbose=logical(cfg.verbose) || options.Verbose);

    disp("Minimal Agent SDK Prototype - Ollama (type ""quit"" to exit)");
    disp("===========================================================");

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

function add_sdk_path(sdkPath)
    if sdkPath ~= ""
        if ~isfolder(sdkPath)
            error("agent:sdkPathNotFound", ...
                "SDK path does not exist. Update sdk_path in config.json: %s", sdkPath);
        end
        addpath(genpath(sdkPath));
    end

    if ~exist("aisdk.aiAgent", "class")
        error("agent:sdkNotFound", ...
            "ai-agent-sdk is not on the MATLAB path. Set sdk_path in config.json or add it to the path.");
    end
end

function value = resolve_option(optionValue, cfg, fieldName)
    value = optionValue;
    if value == "" && isfield(cfg, fieldName)
        value = string(cfg.(fieldName));
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
