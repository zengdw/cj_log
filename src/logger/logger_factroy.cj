package cj_log.logger

import log.{Logger, LogLevel}
import std.collection.{ArrayList, HashMap}
import cj_log.writer.{Writer, getWriterArray, getWriter, createWriters}
import cj_log.config.LoggerConfig
import cj_log.utils.readSettingFile
import cj_log.converter.converterConfigHandle

class LogLauncher {
    private static var logSettingPath = './logSetting.json'

    static init() {
        let logConfig = readSettingFile(logSettingPath)
        converterConfigHandle(logConfig.converters)
        LoggerFactroy.level = logConfig.level
        LoggerFactroy.loggers = logConfig.loggers
        createWriters(logConfig.writers, logConfig.pattern)
    }
}

public class LoggerFactroy {
    public static var level = LogLevel.INFO
    public static var loggers: ArrayList<LoggerConfig> = ArrayList()
    public static let cacheLoggers: HashMap<String, Logger> = HashMap() /* cjlint-ignore !G.NAM.05*/
    
    public static func createLogger(name: String): Logger {
        var cacheLogger = cacheLoggers.get(name)
        return cacheLogger.getOrDefault {
            let loggerConfig = findParentLoggerConfig(name)
            var logger: Logger
            match (loggerConfig) {
                case Some(l) =>
                    // TODO: 动态创建logger
                    logger = BaseLogger(getWriters(l))
                    logger.withAttrs(("logger", name))
                    logger.level = getLevel(l)
                case None =>
                    logger = BaseLogger(getWriterArray())
                    logger.withAttrs(("logger", name))
                    logger.level = level
            }
            cacheLoggers.add(name, logger)
            return logger
        }
    }

    static func getWriters(l: LoggerConfig): Array<Writer> {
        if (l.writerNames.size == 0) {
            if (!l.additivity) {
                return Array<Writer>()
            } else {
                let loggerConfig = findParentLoggerConfig(l.loggerName)
                return match (loggerConfig) {
                    case Some(l) => getWriters(l)
                    case None => getWriterArray()
                }
            }
        }
        let writers = ArrayList<Writer>()
        for (writerName in l.writerNames) {
            if (let Some(w) <- getWriter(writerName)) {
                writers.add(w)
            }
        }
        return writers.toArray()
    }

    static func getLevel(l: LoggerConfig): LogLevel {
        match (l.level) {
            case Some(l) => l
            case None =>
                if (l.additivity) {
                    let loggerConfig = findParentLoggerConfig(l.loggerName)
                    match (loggerConfig) {
                        case Some(l) => getLevel(l)
                        case None => level
                    }
                } else {
                    LogLevel.INFO
                }
        }
    }

    static func findParentLoggerConfig(name: String): Option<LoggerConfig> {
        var loggerConfig: ?LoggerConfig = None
        for (l in loggers) {
            if (name.startsWith(l.loggerName)) {
                loggerConfig = l
                break
            }
        }
        return loggerConfig
    }
}
