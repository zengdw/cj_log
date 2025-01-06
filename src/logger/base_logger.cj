package cj_log_framework.logger

import log.Logger
import std.io.{BufferedOutputStream, OutputStream}
import log.{LogLevel, Attr, LogRecord}
import std.time.DateTime
import std.collection.ArrayList
import std.sync.AtomicBool
import cj_log_framework.writer.Writer

public class BaseLogger <: Logger {
    let w: Writer
    var _level: LogLevel = LogLevel.INFO
    let _attrs = ArrayList<Attr>()
    let _closed = AtomicBool(false)

    public init(writer: Writer) {
        w = writer
    }

    public mut prop level: LogLevel {
        get() {
            _level
        }
        set(v) {
            _level = v
        }
    }

    public func close() {
        _closed.compareAndSwap(false, true)
        return
    }

    public func isClosed(): Bool {
        _closed.load()
    }

    public func withAttrs(attrs: Array<Attr>): Logger {
        if (attrs.size > 0) {
            _attrs.appendAll(attrs)
        }
        return this
    }

    public func log(level: LogLevel, message: String, attrs: Array<Attr>): Unit {
        if (this.enabled(level)) {
            let record: LogRecord = LogRecord(DateTime.now(), level, message, attrs)
            log(record)
        }
    }

    public func log(level: LogLevel, message: () -> String, attrs: Array<Attr>): Unit {
        if (this.enabled(level)) {
            let record: LogRecord = LogRecord(DateTime.now(), level, message(), attrs)
            log(record)
        }
    }

    public func log(record: LogRecord): Unit {
        if (!isClosed()) {
            let attrs = _attrs.toArray().concat(record.attrs)
            record.attrs = attrs
            w.write(record)
        }
    }
}
