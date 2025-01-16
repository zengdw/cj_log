package cj_log_framework.converter

import std.convert.Parsable

public class LoggerConverter <: AbstactConverter {
    public func convert(record: LogRecord) {
        var logger: String = ""
        for (attr in record.attrs) {
            if (attr[0] == "logger") {
                logger = match (attr[1]) {
                    case s: String => s
                    case i: Int64 => i.toString()
                    case _ => ""
                }
                break
            }
        }

        let firstOptin = getFirstOption()
        if (let Some(o) <- firstOptin) {
            let len = Int64.parse(o)
            if (logger.size <= len) {
              return logger
            }
            return logger[logger.size - len..]
        }
        return logger
    }
}
