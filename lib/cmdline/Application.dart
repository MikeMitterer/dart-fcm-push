part of fcm_push.cmdline;

class Application {
    final Logger _logger = new Logger("fcm_push.cmdline.Application");

    /// Commandline options
    final Options _options;

    /// Application-Config, includes changes made via cmdline ord config-file
    Config __config;

    Application() : _options = new Options();

    Future run(List<String> args) async {
        try {
            final ArgResults argResults = _options.parse(args);
            __config = new Config(argResults);

            _configLogging(_config.loglevel);

            if (argResults.wasParsed(Options._ARG_SETTINGS)) {
                _config.printSettings();
                return;
            }

            if (argResults.wasParsed(Options._ARG_HELP) || _config.hasNoTitle) {
                _options.showUsage();
                return;
            }

            bool foundOptionToWorkWith = false;

            if(_config.hasTitle) {
                foundOptionToWorkWith = true;
                await _sendMessage();
            }

            if (!foundOptionToWorkWith) {
                _options.showUsage();
            }
        }

        on FormatException
        catch (error) {
            _logger.shout(error);
            _options.showUsage();
        }
    }


    // -- private -------------------------------------------------------------

    /// Returns Application-Configuration
    ///
    /// cmdline Args and settings from configfile are considered
    Config get _config {
        if(__config == null) {
            throw new ArgumentError("No configuration available!");
        }
        return __config;
    }

    /// Sends the message
    Future _sendMessage() async {
        final FCM fcm = new FCM(_config.fcm_server_key);

        await Future.forEach(_config.fcm_tokens,(final String token) async {
            final Message fcmMessage = new Message()
                ..to = token
                ..title = _config.title
                ..body = _config.body
            ;

            final String messageID = await fcm.send(fcmMessage);
            _logger.fine("MessageID: $messageID");
        });
    }

    void _configLogging(final String loglevel) {
        Validate.notBlank(loglevel);

        hierarchicalLoggingEnabled = false; // set this to true - its part of Logging SDK

        // now control the logging.
        // Turn off all logging first
        switch (loglevel) {
            case "fine":
            case "debug":
                Logger.root.level = Level.FINE;
                break;

            case "warning":
                Logger.root.level = Level.SEVERE;
                break;

            default:
                Logger.root.level = Level.INFO;
        }

        Logger.root.onRecord.listen(new LogPrintHandler(messageFormat: "%m"));
    }


}
