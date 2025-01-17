package cj_log.writer

import std.io.{OutputStream}
import log.LogRecord
import std.console.Console
import std.collection.HashMap
import log.{LogValue, Attr}
import cj_log.config.LogWriterConfig
import std.reflect.TypeInfo

public class ConsoleWriter <: AbstractWriter {
    let o: OutputStream

    public init() {
        this.o = Console.stdOut
    }

    public func write(record: LogRecord): Unit {
        let message = logFormat(record)
        o.write(message.toArray())
        o.flush()
    }

    public func close() {
        println("ConsoleWriter close")
    }

    public func build(c: LogWriterConfig): Unit {
        this.pattern = c.pattern
    }
}
