package cj_log.writer

internal import std.fs.{File, OpenMode, exists, Directory, canonicalize, Path}

public open class FileWriter <: AbstractWriter {
    var file: ?File = None
    var path = Path("")

    public open func write(record: LogRecord): Unit {
        let message = logFormat(record)
        if (let Some(f) <- file) {
            f.write(message.toArray())
        }
    }

    public open func close(): Unit {
        if (let Some(f) <- file) {
            f.flush()
            f.close()
        }
    }

    public open func build(config: LogWriterConfig): Unit {
        pattern = config.pattern
        var filePath = parse("file", config, "日志文件路径不能为空")

        path = Path(filePath)
        if (!exists(path.parent)) {
            Directory.create(path.parent)
        }
        file = File(path, OpenMode.Append)
    }

    func parse(key: String, c: LogWriterConfig, errMsg: String) {
        match (c.properties.get(key)) {
            case Some(v) => v
            case None => throw Exception(errMsg)
        }
    }
}
