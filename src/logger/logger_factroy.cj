package cj_log_framework.logger

import log.{Logger, LogLevel}
import std.collection.HashMap
import cj_log_framework.context
import cj_log_framework.config.{LoggerConfig, LogWriterConfig}
import cj_log_framework.writer.Writer
import std.collection.ArrayList

public class LoggerFactroy {
    public static func createLogger(name: String): Logger {
        var cacheLogger = context.cacheLoggers.get(name)
        return cacheLogger.getOrDefault {
            let loggerConfig = findParentLoggerConfig(name)
            var logger: Logger
            match (loggerConfig) {
                case Some(l) =>
                    logger = BaseLogger(getWriters(l))
                    logger.withAttrs(("logger", name))
                    logger.level = getLevel(l)
                case None =>
                    logger = BaseLogger(context.writers.toArray())
                    logger.withAttrs(("logger", name))
                    logger.level = context.level
            }
            context.cacheLoggers.put(name, logger)
            return logger
        }
    }

    static func getWriters(l: LoggerConfig): Array<Writer> {
        if (l.writers.size == 0) {
            if (!l.additivity) {
                return Array<Writer>()
            } else {
                let loggerConfig = findParentLoggerConfig(l.logger)
                return match (loggerConfig) {
                    case Some(l) => getWriters(l)
                    case None => context.writers.toArray()
                }
            }
        }
        let writers = ArrayList<Writer>()
        for (writerName in l.writers) {
            var index = 0
            for (writer in context.logConfig.writers) {
                if (writer.name == writerName) {
                    match (context.writers.get(index)) {
                        case Some(w) => writers.append(w)
                        case None => {=>}()
                    }
                    break
                }
                index++
            }
        }
        return writers.toArray()
    }

    static func getLevel(l: LoggerConfig): LogLevel {
        match (l.level) {
            case Some(l) => l
            case None =>
                if (l.additivity) {
                    let loggerConfig = findParentLoggerConfig(l.logger)
                    match (loggerConfig) {
                        case Some(l) => getLevel(l)
                        case None => context.level
                    }
                } else {
                    LogLevel.INFO
                }
        }
    }

    static func findParentLoggerConfig(name: String): Option<LoggerConfig> {
        var loggerConfig: ?LoggerConfig = None
        for (l in context.logConfig.loggers) {
            if (name.startsWith(l.logger)) {
                loggerConfig = l
                break
            }
        }
        return loggerConfig
    }
}
