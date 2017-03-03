part of fcm_push.cmdline;

/// Commandline options
class Options {
    static const APPNAME                      = 'fcm-push';

    static const String _ARG_HELP             = 'help';
    static const String _ARG_SETTINGS         = 'settings';
    static const String _ARG_LOGLEVEL         = 'loglevel';
    static const String _ARG_CONFIG_FILE      = 'config_file';

    static const String _ARG_TO               = 'token';

    final ArgParser _parser;

    Options() : _parser = Options._createParser();

    ArgResults parse(final List<String> args) {
        Validate.notNull(args);
        return _parser.parse(args);
    }

    void showUsage() {
        print("Usage: $APPNAME <options> title [body]");
        _parser.usage.split("\n").forEach((final String line) {
            print("    $line");
        });

        print("");
        print("Sample:");
        print("");
        print("    Send message:");
        print("        $APPNAME 'Hello Android' 'Dart rocks!'");
        print("");
    }

    // -- private -------------------------------------------------------------

    static ArgParser _createParser() {
        final ArgParser parser = new ArgParser()

            ..addFlag(_ARG_HELP,                 abbr: 'h', negatable: false, help: "Shows this message")

            ..addFlag(_ARG_SETTINGS,             abbr: 's', negatable: false, help: "Prints settings")

            ..addOption(_ARG_TO,                 abbr: 't', help: "subject or token")

            ..addOption(_ARG_CONFIG_FILE,        abbr: 'f', help: "Change config file")

            ..addOption(_ARG_LOGLEVEL,           abbr: 'v', help: "Sets the appropriate loglevel", allowed: ['info', 'debug', 'warning'])

        ;

        return parser;
    }
}
