package cj_log_framework.writer

import log.LogRecord
import std.collection.HashMap

public interface Writer {
    func write(record: LogRecord): Unit

    func close(): Unit
}

public abstract class AbstractWriter <: Writer {
    public func logFormat(record: LogRecord): String {
        let time = record.time.toString("yyyy-MM-dd HH:mm:ss")
        let level = record.level.toString()
        let attrMap = HashMap<String, String>()
        for (attr in record.attrs) {
            attrMap.put(
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
}
