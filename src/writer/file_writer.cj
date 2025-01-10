package cj_log_framework.writer

import log.LogRecord
import std.collection.HashMap
import std.fs.{File, OpenMode, exists, Directory}
import cj_log_framework.config.LogWriterConfig

public class FileWriter <: AbstractWriter {
    var f: ?File = None
    var _filePath: ?String = None
    var _fileName: ?String = None
    var _pattern: ?String = None

    public func write(record: LogRecord): Unit {
        let message = logFormat(record)
        f.getOrThrow().write(message.toArray())
    }

    public func close(): Unit {
      f.getOrThrow().close()
    }

    public func build(c: LogWriterConfig): Unit{
        _fileName = c.fileName
        _filePath = c.filePath
        _pattern = c.pattern

        var path = _filePath.getOrThrow {throw Exception("fileWriter的filePath参数为空")}
        if (!exists(path)) {
            Directory.create(path)
        }
        if (!path.endsWith("/")) {
            path = path + "/"
        }
        var name = _fileName.getOrThrow {throw Exception("fileWriter的fileName参数为空")}
        f = File(path + name, OpenMode.Append)
    }
}
