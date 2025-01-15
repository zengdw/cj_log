package cj_log_framework

import log.{Logger, LogLevel}
import cj_log_framework.writer.Writer
import cj_log_framework.config.LoggerConfig
import std.collection.{ArrayList, HashMap}
import cj_log_framework.config.{LogConfig, LogWriterConfig}
import std.reflect.{TypeInfo, ClassTypeInfo}
import cj_log_framework.utils.readSettingFile
import cj_log_framework.writer.AbstractWriter
import cj_log_framework.logger.BaseLogger


var logSettingPath = './logSetting.json'
public var context = Context(readSettingFile(logSettingPath))

public class Context {
    var level: LogLevel
    let writers: ArrayList<Writer> = ArrayList()
    let cacheLoggers: HashMap<String, Logger> = HashMap()
    let logConfig: LogConfig

    public init(logConfig: LogConfig) {
        this.logConfig = logConfig
        level = logConfig.level
        initLog()
    }

    /*
     * 初始化日志
     */
    func initLog() {
        for (w in logConfig.writers) {
            let ti = TypeInfo.get(w.writerClass)
            let cti = match(ti as ClassTypeInfo) {
                case Some(cti) => cti
                case None => throw Exception("${w.writerClass} is not a class type")
            }
            let buildFun = cti.getInstanceFunction("build", TypeInfo.of<LogWriterConfig>())
            let writer = match(cti.construct() as AbstractWriter) {
                case Some(writer) => writer
                case None => throw Exception("${w.writerClass} is not a subclass of cj_log_framework.writer.AbstractWriter")     
            }
            buildFun.apply(writer, w)
            writers.add(writer)
        }
    }
}

public class LoggerFactroy {
    public static func createLogger(name: String): Logger {
        var cacheLogger = context.cacheLoggers.get(name)
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
                    logger = BaseLogger(context.writers.toArray())
                    logger.withAttrs(("logger", name))
                    logger.level = context.level
            }
            context.cacheLoggers.add(name, logger)
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
                    case None => context.writers.toArray()
                }
            }
        }
        let writers = ArrayList<Writer>()
        for (writerName in l.writerNames) {
            var index = 0
            for (writer in context.logConfig.writers) {
                if (writer.writerName == writerName && let Some(w) <- context.writers.get(index)) {
                    writers.add(w)
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
                    let loggerConfig = findParentLoggerConfig(l.loggerName)
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
            if (name.startsWith(l.loggerName)) {
                loggerConfig = l
                break
            }
        }
        return loggerConfig
    }
}
