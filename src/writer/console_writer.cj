package cj_log_framework.writer

import std.io.{OutputStream}
import log.LogRecord
import std.console.Console
import std.collection.HashMap
import log.{LogValue, Attr}

public class ConsoleWriter <: AbstractWriter {
    let o: OutputStream
    let DEFAULT_FORMAT = "%d{yyyy-MM-dd HH:mm:ss} -%5p %logger:%line : %m%n"
    var _pattern: ?String = None

    public init() {
        this.o = Console.stdOut
    }

    public mut prop pattern: ?String {
        get() {
            _pattern
        }
        set(v) {
            _pattern = v
        }
    }

    public func write(record: LogRecord): Unit {
        let message = logFormat(record)
        o.write(message.toArray())
        o.flush()
    }

    public func close() {
    }
}
