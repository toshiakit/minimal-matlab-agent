function [observation, workspace] = tool_evaluate_matlab_code(workspace, code)
%TOOL_EVALUATE_MATLAB_CODE Execute MATLAB code through MCP.
    args = struct("code", string(code), "project_path", string(workspace.projectDir));
    observation = workspace.mcpClient.callTool("evaluate_matlab_code", args);
end
