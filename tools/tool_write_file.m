function result = tool_write_file(path, content)
%TOOL_WRITE_FILE Write text to a file.
    projectRoot = string(fileparts(fileparts(mfilename("fullpath"))));
    path = resolve_write_path(path, projectRoot);
    if ~is_path_within_root(path, projectRoot)
        result = "Error: write_file can only write inside the project root: " + projectRoot;
        return
    end

    parentDir = string(fileparts(path));
    if parentDir ~= "" && ~isfolder(parentDir)
        mkdir(parentDir);
    end

    try
        writelines(string(content), path, WriteMode="overwrite");
    catch ME
        result = "Error: could not write file: " + ME.message;
        return
    end

    result = "Wrote " + strlength(string(content)) + " chars to " + path;
end

function path = resolve_write_path(path, projectRoot)
    path = string(path);
    isWindowsAbsolute = strlength(path) >= 2 && extractBetween(path, 2, 2) == ":";
    isRooted = startsWith(path, "/") || startsWith(path, "\");
    if ~isWindowsAbsolute && ~isRooted
        path = string(fullfile(projectRoot, path));
    end
    path = canonical_path(path);
end

function tf = is_path_within_root(path, projectRoot)
    path = lower(strip_trailing_separator(canonical_path(path)));
    projectRoot = lower(strip_trailing_separator(canonical_path(projectRoot)));
    tf = path == projectRoot || startsWith(path, projectRoot + string(filesep));
end

function path = canonical_path(path)
    path = string(java.io.File(char(path)).getCanonicalPath());
end

function path = strip_trailing_separator(path)
    path = string(path);
    while strlength(path) > 1 && endsWith(path, filesep)
        path = extractBefore(path, strlength(path));
    end
end
