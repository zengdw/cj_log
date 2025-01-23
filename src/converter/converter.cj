package cj_log.converter

internal import log.LogRecord
internal import std.collection.{ArrayList, HashMap}
import std.reflect.{TypeInfo, ClassTypeInfo}
import std.sync.ReentrantMutex
import cj_log.config.ConverterConfig

public let CONVERTER_MAP: HashMap<String, String> = HashMap<String, String>()
public let CONVERTER_CLASS_MAP: HashMap<String, AbstractConverter> = HashMap()
private let MTX = ReentrantMutex()

func initDefaultConverterMap() {
    CONVERTER_MAP.add("d", "cj_log.converter.DateConverter")
    CONVERTER_MAP.add("p", "cj_log.converter.LevelConverter")
    CONVERTER_MAP.add("logger", "cj_log.converter.LoggerConverter")
    CONVERTER_MAP.add("msg", "cj_log.converter.MsgConverter")
    CONVERTER_MAP.add("line", "cj_log.converter.LineConverter")
}

public func converterConfigHandle(converterConfigs: ArrayList<ConverterConfig>) {
    initDefaultConverterMap()
    for (c in converterConfigs) {
        CONVERTER_MAP.add(c.converterKey, c.converterClass)
    }
}

public func createConverter(key: String, fragment: String, optionList: ArrayList<String>): AbstractConverter {
    if (let Some(c) <- CONVERTER_CLASS_MAP.get(fragment)) {
        return c
    }
    synchronized(MTX) {
        if (let Some(c) <- CONVERTER_CLASS_MAP.get(fragment)) {
            return c
        }
        if (let Some(classPath) <- CONVERTER_MAP.get(key)) {
            let cti = match (TypeInfo.get(classPath) as ClassTypeInfo) {
                case Some(cti) => cti
                case None => throw Exception("${classPath} is not a class type")
            }
            let converter = match (cti.construct() as AbstractConverter) {
                case Some(converter) => converter
                case None => throw Exception("${classPath} is not a subclass of cj_log.converter.AbstractConverter")
            }
            converter.addOption(optionList)
            CONVERTER_CLASS_MAP.add(fragment, converter)
            return converter
        }
        let defaultConverter = DefaultConverter(key)
        CONVERTER_CLASS_MAP.add(fragment, defaultConverter)
        return defaultConverter
    }
}

public interface Converter {
    func convert(record: LogRecord): String
}
