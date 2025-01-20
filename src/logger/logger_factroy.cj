package cj_log.logger

import log.{Logger, LogLevel}
import std.collection.{ArrayList, HashMap}
import std.reflect.{TypeInfo, ClassTypeInfo}
import std.sync.ReentrantMutex
import cj_log.writer.{Writer, getWriterArray, getWriter, createWriters}
import cj_log.config.LoggerConfig
import cj_log.utils.readSettingFile
import cj_log.converter.converterConfigHandle

public class LoggerFactroy {
    public static var level = LogLevel.INFO
    public static var loggers: ArrayList<LoggerConfig> = ArrayList()
    public static let cacheLoggers: HashMap<String, Logger> = HashMap() /* cjlint-ignore !G.NAM.05*/

    static let MTX = ReentrantMutex()

    public static func createLogger(name: String): Logger {
        synchronized(MTX) {
            var cacheLogger = cacheLoggers.get(name)
            return cacheLogger.getOrDefault {
                let loggerConfig = findParentLoggerConfig(name)
                var logger: AbstractLogger
                match (loggerConfig) {
                    case Some(l) =>
                        logger = buildLogger(l.loggerClass)
                        logger.build(getLevel(l), getWriters(l), [("logger", name)], l.properties)
                    case None =>
                        logger = DefaultLogger()
                        logger.build(level, getWriterArray(), [("logger", name)], HashMap())
                }
                cacheLoggers.add(name, logger)
                return logger
            }
        }
    }

    private static func buildLogger(loggerClass: ?String) {
        if (let Some(lc) <- loggerClass) {
            let ti = TypeInfo.get(lc)
            let cti = match (ti as ClassTypeInfo) {
                case Some(cti) => cti
                case None => throw Exception("${lc} is not a class type")
            }
            let logger = match (cti.construct() as AbstractLogger) {
                case Some(logger) => logger
                case None => throw Exception("${lc} is not a subclass of cj_log.writer.AbstractWriter")
            }
            return logger
        }
        DefaultLogger()
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
                    level
                }
        }
    }

    static func findParentLoggerConfig(name: String): Option<LoggerConfig> {
        var loggerConfig: ?LoggerConfig = None
        for (l in loggers) {
            if (name.startsWith(l.loggerName) && name != l.loggerName) {
                loggerConfig = l
                break
            }
        }
        return loggerConfig
    }
}

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
