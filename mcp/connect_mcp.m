function client = connect_mcp()
%CONNECT_MCP Start the MATLAB MCP Core Server and return a stdio client.
    serverPath = discover_mcp_server_executable();

    if ~isfile(serverPath)
        error("connect_mcp:serverNotFound", ...
            "MCP Core Server not found: %s", serverPath);
    end

    client = McpClient(serverPath, [ ...
        "--matlab-root=" + string(matlabroot), ...
        "--matlab-display-mode=desktop"]);

    projectDir = string(pwd);
    escapedProjectDir = strrep(projectDir, "'", "''");
    client.callTool("evaluate_matlab_code", struct( ...
        "code", "addpath(genpath('" + escapedProjectDir + "'))", ...
        "project_path", projectDir));
end

function serverPath = discover_mcp_server_executable()
    executableName = "matlab-mcp-core-server";
    if ispc
        executableName = executableName + ".exe";
    end

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

    [status, output] = system("where " + executableName);
    if status == 0
        matches = splitlines(strtrim(string(output)));
        matches = matches(matches ~= "");
        if ~isempty(matches) && isfile(matches(1))
            serverPath = matches(1);
            return
        end
    end

    error("connect_mcp:serverNotFound", ...
        "Could not discover MATLAB MCP Core Server in the standard agentic-toolkits bin directory or on PATH.");
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
