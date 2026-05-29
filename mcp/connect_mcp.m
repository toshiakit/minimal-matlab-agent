function client = connect_mcp(serverPath, matlabRoot)
%CONNECT_MCP Start the MATLAB MCP Core Server and return a stdio client.
    arguments
        serverPath (1,1) string
        matlabRoot (1,1) string = ""
    end

    if serverPath == ""
        error("connect_mcp:serverPathRequired", ...
            "Set mcp_server_path in config.json to the MATLAB MCP Core Server executable.");
    end

    if ~isfile(serverPath)
        error("connect_mcp:serverNotFound", ...
            "MCP Core Server not found: %s", serverPath);
    end

    if matlabRoot == ""
        matlabRoot = string(matlabroot);
    end

    client = McpClient(serverPath, [ ...
        "--matlab-root=" + matlabRoot, ...
        "--matlab-display-mode=desktop"]);

    projectDir = string(pwd);
    escapedProjectDir = strrep(projectDir, "'", "''");
    client.callTool("evaluate_matlab_code", struct( ...
        "code", "addpath(genpath('" + escapedProjectDir + "'))", ...
        "project_path", projectDir));
end
