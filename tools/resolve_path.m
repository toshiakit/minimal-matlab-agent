function path = resolve_path(path)
%RESOLVE_PATH Convert a relative path to an absolute path.
    path = string(path);
    if strlength(path) == 0
        path = string(pwd);
        return
    end

    isWindowsAbsolute = strlength(path) >= 2 && extractBetween(path, 2, 2) == ":";
    isRooted = startsWith(path, "/") || startsWith(path, "\");
    if ~isWindowsAbsolute && ~isRooted
        path = string(fullfile(pwd, path));
    end
end
