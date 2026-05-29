function [observation, workspace] = tool_check_matlab_code(workspace, script_path)
%TOOL_CHECK_MATLAB_CODE Run Code Analyzer through MCP.
    scriptPath = resolve_path(script_path);
    observation = workspace.mcpClient.callTool("check_matlab_code", ...
        struct("script_path", scriptPath));
end
