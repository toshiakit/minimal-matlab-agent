function result = tool_read_file(path)
%TOOL_READ_FILE Read text from a file.
    path = resolve_path(path);
    if ~isfile(path)
        result = "Error: file not found: " + path;
        return
    end

    result = join(readlines(path), newline);
    if strlength(result) == 0
        result = "(empty file)";
    end
end
