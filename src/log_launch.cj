package cj_log_framework

import std.collection.{ArrayList, HashMap}
import cj_log_framework.config.{LogConfig, LogWriterConfig}
import log.{Logger, LogLevel}
import std.reflect.{TypeInfo, ClassTypeInfo}
import cj_log_framework.utils.readSettingFile
import cj_log_framework.writer.AbstractWriter
import cj_log_framework.writer.Writer

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
        for (w in logConfig.writers where w.writerClass != None) {
            let ti = TypeInfo.get(w.writerClass ?? "")
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
            writers.append(writer)
        }
    }
}

public var context = Context(readSettingFile("./logSetting.json"))
