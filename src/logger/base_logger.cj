package cj_log.logger

import log.Logger
import std.io.{BufferedOutputStream, OutputStream}
import log.{LogLevel, Attr, LogRecord}
import std.time.DateTime
import std.collection.ArrayList
import std.sync.AtomicBool
import cj_log.writer.Writer

public class BaseLogger <: Logger {
    var writers: Array<Writer>
    var _level: LogLevel = LogLevel.INFO
    let _attrs = ArrayList<Attr>()
    let _closed = AtomicBool(false)

    public init(writers: Array<Writer>) {
        this.writers = writers
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
        if (_closed.compareAndSwap(false, true)) {
            for (w in writers) {
                w.close()
            }
        }
    }

    public func isClosed(): Bool {
        _closed.load()
    }

    public func withAttrs(attrs: Array<Attr>): Logger {
        if (attrs.size > 0) {
            _attrs.add(all: attrs)
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
            for (w in writers) {
                w.write(record)
            }
        }
    }
}
