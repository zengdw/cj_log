package cj_log_framework.logger

import log.Logger
import cj_log_framework.writer.ConsoleWriter
import std.collection.HashMap

public class LoggerFactroy {
    static let CACHE_LOGGER = HashMap<String, Logger>()

    public static func createLogger(name: String): Logger {
        var loggerO = CACHE_LOGGER.get(name)
        return loggerO.getOrDefault {
            let logger = BaseLogger(ConsoleWriter())
            logger.withAttrs(("loggerName", name))
            CACHE_LOGGER.put(name, logger)
            return logger
        }
    }
}
