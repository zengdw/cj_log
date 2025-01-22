package cj_log.logger

import log.{Logger, LogLevel, Attr, LogRecord}
import std.collection.ArrayList
import std.time.DateTime
import cj_log.writer.AbstractWriter
import cj_log.utils.MDC

public class CjLogger <: Logger {
    private var _level: LogLevel
    private var _attrs = ArrayList<Attr>()
    private var _close = false
    private var _additive = true
    private var name: String
    private var loggerContext: LoggerContext
    private var writers = ArrayList<AbstractWriter>()
    private var parent: ?CjLogger
    private var children = ArrayList<CjLogger>()

    init(name: String, loggerContext: LoggerContext, parent: ?CjLogger, level: LogLevel) {
        this.name = name
        this.loggerContext = loggerContext
        this.parent = parent
        this._level = level
    }

    public mut prop level: LogLevel {
        get() {
            _level
        }
        set(v) {
            _level = v
        }
    }

    public mut prop additive: Bool {
        get() {
            _additive
        }
        set(v) {
            _additive = v
        }
    }

    public prop attrs: ArrayList<Attr> {
        get() {
            _attrs
        }
    }

    func addWriter(writers: ArrayList<AbstractWriter>) {
        this.writers.add(all: writers)
    }

    func createChildLogger(name: String): CjLogger {
        var logger = CjLogger(name, this.loggerContext, this, this.level)
        logger.additive = this.additive
        _attrs.add(("logger", name))
        children.add(logger)
        return logger
    }

    public func close() {
        _close = true
    }

    public func isClosed(): Bool {
        _close
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
            let localMap = MDC.localMap()
            let localMapArr = Array<Attr>(localMap.size, repeat: ('', ''))
            var i = 0
            for ((k, v) in MDC.localMap()) {
                localMapArr[i] = (k, v)
                i += 1
            }
            var attrs1 = attrs.toArray().concat(localMapArr).concat(record.attrs)
            record.attrs = attrs1

            var logger = this
            while (true) {
                for (w in logger.writers) {
                    w.write(record)
                }
                if (logger.additive && let Some(l) <- logger.parent) {
                    logger = l
                }
            }
        }
    }
}
