function [observation, workspace] = tool_run_matlab_file(workspace, script_path)
%TOOL_RUN_MATLAB_FILE Run a MATLAB script through MCP.
    scriptPath = resolve_path(script_path);
    observation = workspace.mcpClient.callTool("run_matlab_file", ...
        struct("script_path", scriptPath));
end
