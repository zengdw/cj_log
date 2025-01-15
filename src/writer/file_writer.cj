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
        if (let Some(f1) <- f) {
            f1.write(message.toArray())
        }
    }

    public func close(): Unit {
        if (let Some(f1) <- f) {
            f1.flush()
            f1.close()
        }
    }

    public func build(c: LogWriterConfig): Unit {
        fileName = c.properties.get("fileName")
        filePath = c.properties.get("filePath")
        pattern = c.properties.get("pattern")

        var path = match (filePath) {
            case Some(v) => v
            case None => throw Exception("fileWriter的filePath参数为空")
        }
        if (!exists(path)) {
            Directory.create(path)
        }
        if (!path.endsWith("/")) {
            path = path + "/"
        }
        var name = match (fileName) {
            case Some(v) => v
            case None => throw Exception("fileWriter的fileName参数为空")
        }
        f = File(path + name, OpenMode.Append)
    }
}
