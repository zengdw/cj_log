package cj_log.writer

import std.convert.Parsable
import std.sync.ReentrantMutex
import compress.zlib.{CompressOutputStream, WrapType,CompressLevel}
import std.fs.remove
import std.sync.Timer
import std.time.DateTime

public class RollingFileWriter <: FileWriter {
    var maxFileSize = 0 // 文件最大大小，单位b 0表示不分隔
    var maxHistory = 0 // 日志文件最长保留天数 0表示不限制
    var i = 0
    let mtx = ReentrantMutex()

    public func write(record: LogRecord): Unit {
        if (let Some(f) <- file) {
            if (maxFileSize > 0 && f.length >= maxFileSize) {
                synchronized(mtx) {
                    if (f.length >= maxFileSize) {
                        var extensionName = path.extensionName
                        var parent = path.parent
                        var fileNameWithoutExtension = path.fileNameWithoutExtension
                        var newFileName = "${fileNameWithoutExtension}.${i}.${extensionName}.gz"
                        i += 1
                        close()
                        compressFile(path, parent.join(newFileName))
                        remove(path)

                        file = File(path, OpenMode.Append)
                    }
                }
            }
        }

        super.write(record)
    }

    private func parse(key: String, c: LogWriterConfig) {
        match (c.properties.get(key)) {
            case Some(v) => Int64.parse(v)
            case None => 0
        }
    }

    public func build(config: LogWriterConfig): Unit {
        super.build(config)
        maxFileSize = parse("maxFileSize", config) * 1024 * 1024
        maxHistory = parse("maxHistory", config)

        if (maxHistory > 0) {
            Timer.repeat(Duration.Zero, Duration.day, { => 
                var parent = path.parent
                Directory.walk(parent) {
                    fileInfo => 
                    let createionTime = fileInfo.creationTime
                    if (DateTime.now() > createionTime + Duration.day * maxHistory) {
                        remove(fileInfo.path)
                    }
                    return true
                }
            })
        }
    }

    func compressFile(srcFileName: Path, destFileName: Path): Int64 {
        var count: Int64 = 0
        var srcFile: File = File(srcFileName, Read)
        var destFile: File = File(destFileName, Write)

        var tempBuf: Array<UInt8> = Array<UInt8>(1024, repeat: 0)
        var compressOutputStream: CompressOutputStream = CompressOutputStream(destFile, wrap: GzipFormat, compressLevel: BestCompression, bufLen: 10000)
        while (true) {
            var readNum = srcFile.read(tempBuf)
            if (readNum > 0) {
                compressOutputStream.write(tempBuf.slice(0, readNum).toArray())
                count += readNum
            } else {
                break
            }
        }
        compressOutputStream.flush()
        compressOutputStream.close()

        srcFile.close()
        destFile.close()
        return count
    }
}
