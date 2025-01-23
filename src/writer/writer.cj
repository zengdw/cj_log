package cj_log.writer

internal import log.LogRecord
internal import std.collection.{ArrayList, HashMap}
import std.reflect.{TypeInfo, ClassTypeInfo}
internal import cj_log.config.{LogWriterConfig}

public func createWriters(writerConfigs: ArrayList<LogWriterConfig>, pattern: ?String) {
    let writerMap: HashMap<String, AbstractWriter> = HashMap()
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
        writerMap.add(w.writerName, writer)
    }
    return writerMap
}

public interface Writer {
    func write(record: LogRecord): Unit

    func close(): Unit

    func build(config: LogWriterConfig): Unit
}
