function [observation, workspace] = tool_detect_matlab_toolboxes(workspace)
%TOOL_DETECT_MATLAB_TOOLBOXES List installed MATLAB toolboxes through MCP.
    observation = workspace.mcpClient.callTool("detect_matlab_toolboxes", struct());
end
