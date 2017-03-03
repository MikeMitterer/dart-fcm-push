part of fcm_push.cmdline;

/**
 * Defines default-configurations.
 * Most of these configs can be overwritten by commandline args
 * or via settings in config-file
 */
class Config {
    final Logger _logger = new Logger("fcm_push.cmdline.Config");

    static const String _CONFIG_PATH    = ".";
    static const String _CONFIG_FILE    = "fcm-push.yaml";

    static const String _CONFIG_SERVER_KEY  = "fcm.server.key";

    final ArgResults _argResults;
    final Map<String,dynamic> _settings = new Map<String,dynamic>();

    Config(this._argResults) {

        _settings[Options._ARG_LOGLEVEL]            = 'info';
        _settings[Options._ARG_CONFIG_FILE]         = path.join(_CONFIG_PATH,_CONFIG_FILE);

        _settings[Config._CONFIG_SERVER_KEY]        = "";
        _settings[Options._ARG_TO]                  = "";

        _overwriteSettingsForConfigFile();
        _overwriteSettingsWithConfigFile();
        _overwriteSettingsWithArgResults();
    }

    String get configfile       => _settings[Options._ARG_CONFIG_FILE];

    String get loglevel         => _settings[Options._ARG_LOGLEVEL];

    String get fcm_server_key   => _settings[Config._CONFIG_SERVER_KEY];
    List<String> get fcm_tokens {
        if(_settings[Options._ARG_TO] is! List) {
            return <String>[ _settings[Options._ARG_TO] ];
        }
        return _settings[Options._ARG_TO];
    }

    List<String> get params => _argResults.rest;

    String get title => hasTitle ? params[0] : '';

    String get body => hasBody ? params[1] : '';

    bool get hasTitle => params.length >= 1 && params[0].isNotEmpty;
    bool get hasNoTitle => !hasTitle;

    bool get hasBody => params.length >= 2 && params[1].isNotEmpty;
    bool get hasNoBody => !hasBody;

    Map<String,String> get settings {
        final Map<String,String> settings = new Map<String,String>();

        settings["loglevel"]            = loglevel;
        settings["Config file"]         = configfile;

        settings["FCM Sever key"]       = fcm_server_key;
        settings["FCM Token"]           = fcm_tokens.join("\n");

        return settings;
    }


    void printSettings() {

        int getMaxKeyLength() {
            int length = 0;
            settings.keys.forEach((final String key) => length = math.max(length,key.length));
            return length;
        }

        final int maxKeyLength = getMaxKeyLength();
        final int distSecondLine = maxKeyLength + 7;

        String prepareKey(final String key) {
            return "${key[0].toUpperCase()}${key.substring(1)}:".padRight(maxKeyLength + 1);
        }

        print("Settings:");
        settings.forEach((final String key,String value) {
            if(value.contains("\n")) {
                print("    ${prepareKey(key)}");
                print("${_penGreen("".padRight(distSecondLine -1) + value.split("\n").join("\n".padRight(distSecondLine)))}");

            } else {
                print("    ${prepareKey(key)} ${_penGreen(value)}");
            }
        });
    }

    // -- private -------------------------------------------------------------

    /// Default-Settings will be overwritten by cmdline Arguments
    ///
    /// This has higher priority then settings in config-file
    void _overwriteSettingsWithArgResults() {

        if(_argResults.wasParsed(Options._ARG_LOGLEVEL)) {
            _settings[Options._ARG_LOGLEVEL] = _argResults[Options._ARG_LOGLEVEL];
        }
    }

    /// Settings for config-file hast highest priority - can only be overwritten
    /// with cmdline param
    ///
    void _overwriteSettingsForConfigFile() {

        if(_argResults.wasParsed(Options._ARG_CONFIG_FILE)) {
            _settings[Options._ARG_CONFIG_FILE] = _argResults[Options._ARG_CONFIG_FILE];
        }
    }

    /// Default-Settings will be overwritten by settings in config-file
    void _overwriteSettingsWithConfigFile() {
        final File file = new File(configfile);
        if(!file.existsSync()) {
            return;
        }
        final yaml.YamlMap map = yaml.loadYaml(file.readAsStringSync());
        _settings.keys.forEach((final String key) {
            if(map != null && map.containsKey(key)) {
                _settings[key] = map[key];
                _logger.fine("Found $key in $configfile: ${map[key]}");
            }
        });
    }
}