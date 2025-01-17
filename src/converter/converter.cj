package cj_log.converter

internal import log.LogRecord
internal import std.collection.{ArrayList, HashMap}
import std.reflect.{TypeInfo, ClassTypeInfo}
import cj_log.config.ConverterConfig

private let DEFAULT_CONVERTER_MAP = HashMap<String, String>()
public let CONVERTER_MAP: HashMap<String, String> = DEFAULT_CONVERTER_MAP
public let CONVERTER_CLASS_MAP: HashMap<String, AbstactConverter> = HashMap()

func initDefaultConverterMap() {
    DEFAULT_CONVERTER_MAP.add("d", "cj_log.converter.DateConverter")
    DEFAULT_CONVERTER_MAP.add("date", "cj_log.converter.DateConverter")
    DEFAULT_CONVERTER_MAP.add("p", "cj_log.converter.LevelConverter")
    DEFAULT_CONVERTER_MAP.add("level", "cj_log.converter.LevelConverter")
    DEFAULT_CONVERTER_MAP.add("logger", "cj_log.converter.LoggerConverter")
    DEFAULT_CONVERTER_MAP.add("msg", "cj_log.converter.MsgConverter")
    DEFAULT_CONVERTER_MAP.add("m", "cj_log.converter.MsgConverter")
    DEFAULT_CONVERTER_MAP.add("line", "cj_log.converter.LineConverter")
}

public func converterConfigHandle(converterConfigs: ArrayList<ConverterConfig>) {
    initDefaultConverterMap()
    for (c in converterConfigs) {
        CONVERTER_MAP.add(c.converterKey, c.converterClass)
    }
}

public func createConverter(key: String, fragment: String, optionList: ArrayList<String>): AbstactConverter {
    if (let Some(c) <- CONVERTER_CLASS_MAP.get(fragment)) {
        return c
    }
    if (let Some(classPath) <- CONVERTER_MAP.get(key)) {
        let cti = match (TypeInfo.get(classPath) as ClassTypeInfo) {
            case Some(cti) => cti
            case None => throw Exception("${classPath} is not a class type")
        }
        let converter = match (cti.construct() as AbstactConverter) {
            case Some(converter) => converter
            case None => throw Exception("${classPath} is not a subclass of cj_log.converter.AbstactConverter")
        }
        converter.addOption(optionList)
        CONVERTER_CLASS_MAP.add(fragment, converter)
        return converter
    }
    let defaultConverter = DefaultConverter(key)
    CONVERTER_CLASS_MAP.add(fragment, defaultConverter)
    return defaultConverter
}

public interface Converter {
    func convert(record: LogRecord): String
}
