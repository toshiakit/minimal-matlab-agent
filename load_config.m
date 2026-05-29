function cfg = load_config()
%LOAD_CONFIG Read project configuration from config.json.
    configPath = fullfile(fileparts(mfilename("fullpath")), "config.json");
    cfg = jsondecode(fileread(configPath));
end
