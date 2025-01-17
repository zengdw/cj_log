package cj_log.writer

import log.LogRecord
import std.collection.{HashMap, ArrayList}
import std.fs.{File, OpenMode, exists, Directory}
import std.convert.Parsable
import std.sync.ReentrantMutex
import cj_log.config.LogWriterConfig

public class FileWriter <: AbstractWriter {
    var f: ?File = None
    var filePath = ""
    var fileName = ""
    var maxFileSize = 0
    var maxFileCount = 0
    var maxTime = 0
    var count = 0
    var index = 0
    let mtx = ReentrantMutex()

    public func write(record: LogRecord): Unit {
        let message = logFormat(record)
        createFile()
        if (let Some(f1) <- f) {
            f1.write(message.toArray())
            f1.flush()
        }
    }

    public func close(): Unit {
        if (let Some(f1) <- f) {
            f1.flush()
            f1.close()
        }
    }

    private func createFile() {
        if (maxFileSize > 0 && f.getOrThrow().length >= maxFileSize) { /** cjlint-ignore !G.ERR.03 */
            synchronized(mtx) {
                if (f.getOrThrow().length < maxFileSize) { /** cjlint-ignore !G.ERR.03 */
                    return
                }
                let arr = ArrayList<String>(fileName.split("."))
                if (index == 0) {
                    arr.add(index.toString(), at: arr.size - 1)
                } else {
                    arr[arr.size - 2] = index.toString()
                }
                index += 1
                fileName = String.join(arr.toArray(), delimiter: ".")
                close()
                f = File(filePath + fileName, OpenMode.Append)
            }
        }
    }

    public func build(c: LogWriterConfig): Unit {
        pattern = c.pattern
        fileName = parse("fileName", c, "fileWriter的fileName参数为空")
        filePath = parse("filePath", c, "fileWriter的filePath参数为空")
        maxFileSize = parse("maxFileSize", c) * 1024 * 1024
        maxFileCount = parse("maxFileCount", c)
        maxTime = parse("maxTime", c)

        if (!exists(filePath)) {
            Directory.create(filePath)
        }
        if (!filePath.endsWith("/")) {
            filePath = filePath + "/"
        }
        f = File(filePath + fileName, OpenMode.Append)
    }

    private func parse(key: String, c: LogWriterConfig) {
        match (c.properties.get(key)) {
            case Some(v) => Int64.parse(v)
            case None => 0
        }
    }

    private func parse(key: String, c: LogWriterConfig, errMsg: String) {
        match (c.properties.get(key)) {
            case Some(v) => v
            case None => throw Exception(errMsg)
        }
    }
}
