package cj_log.writer

import log.LogRecord
import std.collection.{ArrayList, HashMap}
import std.reflect.{TypeInfo, ClassTypeInfo}
import cj_log.config.{LogWriterConfig}

let CACHE_WRITER_MAP: HashMap<String, Writer> = HashMap()

public func getWriterArray() {
    CACHE_WRITER_MAP.values().toArray()
}

public func getWriter(writerName: String) {
    CACHE_WRITER_MAP.get(writerName)
}

public func createWriters(writerConfigs: ArrayList<LogWriterConfig>, pattern: ?String) {
    for (w in writerConfigs) {
        let ti = TypeInfo.get(w.writerClass)
        let cti = match (ti as ClassTypeInfo) {
            case Some(cti) => cti
            case None => throw Exception("${w.writerClass} is not a class type")
        }
        let buildFun = cti.getInstanceFunction("build", TypeInfo.of<LogWriterConfig>())
        let writer = match (cti.construct() as AbstractWriter) {
            case Some(writer) => writer
            case None => throw Exception("${w.writerClass} is not a subclass of cj_log.writer.AbstractWriter")
        }
        ifNone(w.pattern) {
            w.pattern = pattern
        }
        buildFun.apply(writer, w)
        CACHE_WRITER_MAP.add(w.writerName, writer)
    }
}

public interface Writer {
    func write(record: LogRecord): Unit

    func close(): Unit

    func build(c: LogWriterConfig): Unit
}
