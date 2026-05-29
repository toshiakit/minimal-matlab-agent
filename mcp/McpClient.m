classdef McpClient < handle
%MCPCLIENT MCP client that communicates with a server over stdio.

    properties (Access=private)
        Counter (1,1) double = 0
        Stdio
    end

    methods
        function obj = McpClient(serverPath, args)
            arguments
                serverPath (1,1) string
                args (1,:) string = string.empty
            end

            projectDir = fileparts(mfilename("fullpath"));
            if count(py.sys.path(), projectDir) == 0
                py.sys.path().insert(int32(0), projectDir);
            end

            obj.Stdio = py.importlib.import_module("mcp_stdio");
            obj.Stdio.start(py.list([serverPath, args]));

            obj.sendRequest("initialize", struct( ...
                "protocolVersion", "2024-11-05", ...
                "capabilities", struct(), ...
                "clientInfo", struct("name", "Minimal-Agent-SDK", "version", "0.1")));
            obj.sendNotification("notifications/initialized");
        end

        function result = callTool(obj, toolName, args)
            arguments
                obj (1,1) McpClient
                toolName (1,1) string
                args (1,1) struct = struct()
            end

            response = obj.sendRequest("tools/call", struct("name", toolName, "arguments", args));
            if isfield(response, "error")
                error("McpClient:serverError", "%s", jsonencode(response.error));
            end

            content = response.result.content;
            if ~iscell(content)
                content = num2cell(content);
            end
            result = join(cellfun(@(c) string(c.text), content), "");
        end

        function disconnect(obj)
            if ~isempty(obj.Stdio)
                try
                    obj.Stdio.terminate();
                catch
                end
                obj.Stdio = [];
            end
        end

        function delete(obj)
            obj.disconnect();
        end
    end

    methods (Access=private)
        function response = sendRequest(obj, method, params)
            obj.Counter = obj.Counter + 1;
            msg = struct("jsonrpc", "2.0", "id", obj.Counter, "method", method);
            if nargin > 2
                msg.params = params;
            end
            obj.Stdio.write_line(jsonencode(msg));
            response = obj.readResponse(obj.Counter);
        end

        function sendNotification(obj, method)
            obj.Stdio.write_line(jsonencode(struct("jsonrpc", "2.0", "method", method)));
        end

        function response = readResponse(obj, expectedId)
            timeout = 120;
            tic;
            while toc < timeout
                line = string(obj.Stdio.read_line());
                if strlength(line) == 0
                    if obj.Stdio.poll() ~= py.None
                        error("McpClient:serverExit", ...
                            "Server process terminated unexpectedly.\n%s", ...
                            string(obj.Stdio.get_stderr()));
                    end
                    pause(0.05);
                    continue
                end

                try
                    data = jsondecode(line);
                catch
                    continue
                end

                if isfield(data, "id") && data.id == expectedId
                    response = data;
                    return
                end
            end
            error("McpClient:timeout", "Timed out waiting for response id=%d", expectedId);
        end
    end
end
