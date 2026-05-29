function [observation, workspace] = tool_run_matlab_test_file(workspace, script_path)
%TOOL_RUN_MATLAB_TEST_FILE Run a MATLAB test file through MCP.
    scriptPath = resolve_path(script_path);
    observation = workspace.mcpClient.callTool("run_matlab_test_file", ...
        struct("script_path", scriptPath));
end
