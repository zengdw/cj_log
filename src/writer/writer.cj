package cj_log_framework.writer

import log.LogRecord
import std.collection.HashMap
import cj_log_framework.config.LogWriterConfig
import std.reflect.TypeInfo

public interface Writer {
    func write(record: LogRecord): Unit

    func close(): Unit

    func build(c: LogWriterConfig): Unit
}

public abstract class AbstractWriter <: Writer {
    let DEFAULT_PATTERN: String = "%{d(yyyy-MM-dd HH:mm:ss)} -%{5p} %{logger}:%{line} %{msg}"
    var pattern: ?String = None

    public func logFormat(record: LogRecord): String {
        let time = record.time.format("yyyy-MM-dd HH:mm:ss")
        let level = record.level.toString()
        let attrMap = HashMap<String, String>()
        for (attr in record.attrs) {
            attrMap.add(
                attr[0],
                match (attr[1]) {
                    case s: String => s
                    case i: Int64 => i.toString()
                    case _ => ""
                }
            )
        }
        let loggerName = attrMap.get("logger") ?? ""
        let line = attrMap.get("line") ?? ""
        let message = "${time} -${level} ${loggerName}:${line} : ${record.message} \n"
        return message
    }

    public func write(record: LogRecord): Unit 
}
