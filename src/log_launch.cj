package cj_log_framework

import cj_log_framework.utils.readSettingFile
import std.reflect.{TypeInfo, ClassTypeInfo}
import cj_log_framework.config.{LogWriterConfig, LoggerConfig}
import std.collection.ArrayList
import cj_log_framework.writer.{ConsoleWriter, FileWriter, Writer}
import log.{LogLevel, Logger}
import std.collection.HashMap
import cj_log_framework.config.LogConfig

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
        for (w in logConfig.writers where w.name != None) {
            if ("consoleWriter" == (w.name ?? "")) {
                let consoleWriter = ConsoleWriter()
                consoleWriter.pattern = w.pattern
                writers.append(consoleWriter)
            } else if ("fileWriter" == (w.name ?? "")) {
                let fileWriter = FileWriter(w.filePath ?? "", w.fileName ?? "", w.pattern)
                writers.append(fileWriter)
            }
        }
    }
}

public var context = Context(readSettingFile("./logSetting.json"))
