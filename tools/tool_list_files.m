function result = tool_list_files(path, recursive)
%TOOL_LIST_FILES List files and directories.
    arguments
        path (1,1) string
        recursive (1,1) logical = false
    end

    path = resolve_path(path);
    if ~isfolder(path)
        result = "Error: directory not found: " + path;
        return
    end

    if recursive
        entries = dir(fullfile(path, "**", "*"));
    else
        entries = dir(path);
    end

    names = strings(0);
    for k = 1:numel(entries)
        name = string(entries(k).name);
        if name == "." || name == ".."
            continue
        end

        if recursive
            itemPath = string(fullfile(entries(k).folder, entries(k).name));
        else
            itemPath = name;
        end

        if entries(k).isdir
            itemPath = itemPath + filesep;
        end
        names(end+1) = itemPath; %#ok<AGROW>
    end

    if isempty(names)
        result = "(empty directory)";
    else
        result = join(names, newline);
    end
end
