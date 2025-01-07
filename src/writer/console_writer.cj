package cj_log_framework.writer

import std.io.{OutputStream}
import log.LogRecord
import std.console.Console
import std.collection.HashMap
import log.{LogValue, Attr}

public class ConsoleWriter <: Writer {
    let o: OutputStream
    let DEFAULT_FORMAT = "%d{yyyy-MM-dd HH:mm:ss.SSS} -%5p %-40.40logger{39}: %m%n"

    public init() {
        this.o = Console.stdOut
    }

    public func write(record: LogRecord): Unit {
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
        let loggerName = attrMap.get("loggerName") ?? ""
        let line = attrMap.get("line") ?? ""
        let message = "${time} -${level} ${loggerName}:${line} : ${record.message} \n"
        o.write(message.toArray())
        o.flush()
    }
}
