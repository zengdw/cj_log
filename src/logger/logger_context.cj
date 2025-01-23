package cj_log.logger

import std.collection.{HashMap, ArrayList}
import log.LogLevel
import std.sync.ReentrantMutex
import cj_log.writer.AbstractWriter
import cj_log.config.{LogConfig, LoggerConfig}

public class LoggerContext {
    public static let ROOT_LOGGER_NAME = "ROOT"

    private var loggerCache = HashMap<String, CjLogger>()
    private var root: CjLogger
    private var _level: ?LogLevel = None
    private var _pattern: ?String = None
    private var writers: HashMap<String, AbstractWriter>
    private var mtx = ReentrantMutex()

    public init(logConfig: LogConfig, writers: HashMap<String, AbstractWriter>) {
        this.writers = writers
        root = CjLogger(ROOT_LOGGER_NAME, None, logConfig.level)
        root.writers  = getWeriters(logConfig.writerNames)
        loggerCache.add(ROOT_LOGGER_NAME, root)

        createDefaultLogger(logConfig.loggers)
    }

    public mut prop level: ?LogLevel {
        get() {
            _level
        }
        set(v) {
            _level = v
        }
    }
    public mut prop pattern: ?String {
        get() {
            _pattern
        }
        set(v) {
            _pattern = v
        }
    }

    func getWeriters(writerNames: ArrayList<String>) {
        var ws = ArrayList<AbstractWriter>()
        for (name in writerNames) {
            if (let Some(w) <- writers.get(name)) {
                ws.add(w)
            }
        }
        return ws
    }

    func createDefaultLogger(configs: ArrayList<LoggerConfig>) {
        configs.sortBy(
            comparator: {
                c1, c2 => if (c1.loggerName.size > c2.loggerName.size) {
                    Ordering.GT
                } else if (c1.loggerName.size < c2.loggerName.size) {
                    Ordering.LT
                } else {
                    Ordering.EQ
                }
            })
        for (config in configs) {
            var loggerName = config.loggerName
            var parent = findParentLogger(loggerName)
            var logger = parent.createChildLogger(loggerName)
            logger.level = config.level ?? parent.level
            logger.writers = parent.writers
            logger.additive = config.additivity
            loggerCache.add(loggerName, logger)
        }
    }

    public func getLogger(name: String): CjLogger {
        var logger = loggerCache.get(name)
        if (let Some(l) <- logger) {
            return l
        }
        synchronized(mtx) {
            logger = loggerCache.get(name)
            if (let Some(l) <- logger) {
                return l
            }

            var parent = findParentLogger(name)
            var l = parent.createChildLogger(name)
            loggerCache.add(name, l)
            return l
        }
    }

    func findParentLogger(loggerName: String): CjLogger {
        var end = loggerName.lastIndexOf(".")
        if (let Some(e) <- end) {
            var fragment = loggerName[0..e]
            if (let Some(parent) <- loggerCache.get(fragment)) {
                return parent
            } else {
                return findParentLogger(fragment)
            }
        } else {
            if (let Some(parent) <- loggerCache.get(loggerName)) {
                return parent
            } else {
                return root
            }
        }
    }
}
