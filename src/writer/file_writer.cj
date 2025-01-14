package cj_log_framework.writer

import log.LogRecord
import std.collection.HashMap
import std.fs.{File, OpenMode, exists, Directory}
import cj_log_framework.config.LogWriterConfig

public class FileWriter <: AbstractWriter {
    var f: ?File = None
    var filePath: ?String = None
    var fileName: ?String = None
    var pattern: ?String = None

    public func write(record: LogRecord): Unit {
        let message = logFormat(record)
        f.getOrThrow().write(message.toArray())
    }

    public func close(): Unit {
        f.getOrThrow().close()
    }

    public func build(c: LogWriterConfig): Unit {
        fileName = c.fileName
        filePath = c.filePath
        pattern = c.pattern

        var path = filePath.getOrThrow {throw Exception("fileWriter的filePath参数为空")}
        if (!exists(path)) {
            Directory.create(path)
        }
        if (!path.endsWith("/")) {
            path = path + "/"
        }
        var name = fileName.getOrThrow {throw Exception("fileWriter的fileName参数为空")}
        f = File(path + name, OpenMode.Append)
    }
}
