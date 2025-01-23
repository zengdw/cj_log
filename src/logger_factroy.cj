package cj_log

public class LoggerFactroy {

    public static func getLogger(name: String) {
        var loggerName = name
        if (name.endsWith(".cj")) {
            loggerName = name[0..name.size - 3]
        }
        let loggerContext = ContextInitializer.getInstance().defaultLoggerContext
        return loggerContext.getLogger(loggerName)
    }

}
