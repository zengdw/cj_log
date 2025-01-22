package cj_log

import cj_log.logger.LoggerContext
import cj_log.utils.ContextInitializer


public class LoggerFactroy {
    private static let UNINITIALIZED = 0
    private static let SUCCESSFUL_INITIALIZATION = 1
    private static let INITIALIZATION_STATE = UNINITIALIZED

    public static func getLogger(name: String) {
        var loggerName = name
        if (name.endsWith(".cj")) {
            loggerName = name[0..name.size - 3]
        }
        let loggerContext = getLoggerContext()
        return loggerContext.getLogger(loggerName)
    }

    static func getLoggerContext(): LoggerContext {
        if (INITIALIZATION_STATE == UNINITIALIZED) {
            ContextInitializer.SINGLETON
        }
        ContextInitializer.SINGLETON.defaultLoggerContext
    }

}
