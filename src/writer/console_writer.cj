package cj_log_framework.writer

import std.io.{OutputStream}
import log.LogRecord
import std.console.Console
import std.collection.HashMap
import log.{LogValue, Attr}
import cj_log_framework.config.LogWriterConfig
import std.reflect.TypeInfo

public class ConsoleWriter <: AbstractWriter {
    let o: OutputStream
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

    public func build(c: LogWriterConfig): Unit {
        this.pattern = c.pattern
    }
}
