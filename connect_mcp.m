function client = connect_mcp(projectDir)
%CONNECT_MCP Connect to MATLAB MCP Server using native SDK stdio transport.
    if nargin == 0
        projectDir = fileparts(mfilename("fullpath"));
    end
    serverPath = discover_mcp_server_executable();

    if ~isfile(serverPath)
        error("connect_mcp:serverNotFound", ...
            "MATLAB MCP Server not found: %s", serverPath);
    end

    client = aisdk.MCPClient([serverPath, ...
        "--matlab-root=" + string(matlabroot), ...
        "--initial-working-folder=" + string(projectDir), ...
        "--matlab-session-mode=new", ...
        "--matlab-display-mode=nodesktop"], ...
        Transport="stdio", TimeOut=120);

    try
        serverTools = client.Tools;
        evaluator = serverTools(string({serverTools.Name}) == "evaluate_matlab_code");
        if isempty(evaluator)
            error("connect_mcp:missingTool", ...
                "MATLAB MCP Server does not provide evaluate_matlab_code.");
        end
        escapedProjectDir = strrep(string(projectDir), "'", "''");
        result = evaluate(evaluator, struct( ...
            "code", "addpath('" + escapedProjectDir + "')", ...
            "project_path", string(projectDir)));
        if isfield(result, "isError") && result.isError
            error("connect_mcp:initializationFailed", ...
                "MATLAB MCP Server initialization failed: %s", jsonencode(result));
        end
    catch exception
        delete(client);
        rethrow(exception);
    end
end

function serverPath = discover_mcp_server_executable()
    executableNames = ["matlab-mcp-server", "matlab-mcp-core-server"];
    if ispc
        executableNames = executableNames + ".exe";
    end

    for executableName = executableNames
        candidates = [
            fullfile(userpath_root(), ".matlab", "agentic-toolkits", "bin", executableName)
            fullfile(getenv("USERPROFILE"), ".matlab", "agentic-toolkits", "bin", executableName)
            fullfile(getenv("HOME"), ".matlab", "agentic-toolkits", "bin", executableName)
        ];

        for idx = 1:numel(candidates)
            candidate = string(candidates(idx));
            if candidate ~= "" && isfile(candidate)
                serverPath = candidate;
                return
            end
        end

        if ispc
            searchCommand = "where " + executableName;
        else
            searchCommand = "command -v " + executableName;
        end

        [status, output] = system(searchCommand);
        if status == 0
            matches = splitlines(strtrim(string(output)));
            matches = matches(matches ~= "");
            if ~isempty(matches) && isfile(matches(1))
                serverPath = matches(1);
                return
            end
        end
    end

    error("connect_mcp:serverNotFound", ...
        "Could not discover MATLAB MCP Server in the standard agentic-toolkits bin directory or on PATH.");
end

function root = userpath_root()
    pathValue = string(userpath);
    if pathValue == ""
        root = "";
        return
    end

    paths = split(pathValue, pathsep);
    paths = paths(paths ~= "");
    if isempty(paths)
        root = "";
    else
        root = string(fileparts(paths(1)));
    end
end
