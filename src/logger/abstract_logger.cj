package cj_log.logger

internal import log.{Logger, LogLevel, Attr, LogRecord}
internal import std.collection.{ArrayList, HashMap}
internal import std.sync.AtomicBool
internal import std.time.DateTime
internal import cj_log.writer.Writer
internal import cj_log.config.LoggerConfig

public abstract class AbstractLogger <: Logger {
    private var _writers = Array<Writer>()
    private var _level = LogLevel.INFO
    private var _attrs = ArrayList<Attr>()
    private let _closed = AtomicBool(false)

    public mut prop level: LogLevel {
        get() {
            _level
        }
        set(v) {
            _level = v
        }
    }

    public mut prop writers: Array<Writer> {
        get() {
            _writers
        }
        set(v) {
            _writers = v
        }
    }

    public prop attrs: ArrayList<Attr> {
        get() {
            _attrs
        }
    }

    public prop closed: AtomicBool {
        get() {
            _closed
        }
    }

    public func isClosed(): Bool {
        _closed.load()
    }

    public open func withAttrs(attrs: Array<Attr>): Logger {
        if (attrs.size > 0) {
            _attrs.add(all: attrs)
        }
        return this
    }

    public func build(level: LogLevel, writers: Array<Writer>, attrs: Array<Attr>, properties: HashMap<String, String>): Unit {
        this.level = level
        this.writers = writers
        this.withAttrs(attrs)

        doBuild(properties)
    }

    public open func doBuild(properties: HashMap<String, String>): Unit

    public open func log(level: LogLevel, message: String, attrs: Array<Attr>): Unit {
        if (this.enabled(level)) {
            let record: LogRecord = LogRecord(DateTime.now(), level, message, attrs)
            log(record)
        }
    }

    public open func log(level: LogLevel, message: () -> String, attrs: Array<Attr>): Unit {
        if (this.enabled(level)) {
            let record: LogRecord = LogRecord(DateTime.now(), level, message(), attrs)
            log(record)
        }
    }
}
