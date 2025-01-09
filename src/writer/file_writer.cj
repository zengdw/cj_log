package cj_log_framework.writer

import log.LogRecord
import std.collection.HashMap
import std.fs.{File, OpenMode, exists, Directory}

public class FileWriter <: AbstractWriter {
    let DEFAULT_FORMAT = "%d{yyyy-MM-dd HH:mm:ss} -%5p %logger:%line : %m%n"
    var f: File
    var _filePath: String
    var _fileName: String
    var _pattern: ?String

    public init(filePath: String, fileName: String, pattern: ?String) {
        _filePath = filePath
        _fileName = fileName
        _pattern = pattern
        if (!exists(filePath)) {
            Directory.create(filePath)
        }
        var v = filePath
        if (!filePath.endsWith("/")) {
            v = filePath + "/"
        }
        f = File(v + fileName, OpenMode.Append)
    }

    public func write(record: LogRecord): Unit {
        let message = logFormat(record)
        f.write(message.toArray())
    }

    public func close(): Unit {
      println("FileWriter close")
      f.close()
    }
}
