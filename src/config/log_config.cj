package cj_log.config

internal import log.LogLevel
internal import std.collection.{ArrayList, HashMap, forEach, filter}
internal import serialization.serialization.{Serializable, DataModelStruct, DataModel, field, DataModelString, DataModelSeq, 
    DataModelBool, Field}

public class LogConfig <: Serializable<LogConfig> {
    public let level: LogLevel

    public LogConfig(
        level: String,
        public let writers: ArrayList<LogWriterConfig>,
        public let loggers: ArrayList<LoggerConfig>,
        public let converters: ArrayList<ConverterConfig>,
        public let pattern: ?String
    ) {
        this.level = logLevel(level)
    }

    public func serialize(): DataModel {
        return DataModelStruct()
            .add(field("level", level.name))
            .add(field("writers", writers))
            .add(field("loggers", loggers))
            .add(field("converters", converters))
            .add(field("pattern", pattern))
    }

    public static func deserialize(dm: DataModel): LogConfig {
        let dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let result = LogConfig(
            get(dms, "level").getOrDefault {"INFO"},
            match (dms.get("writers")) {
                case data: DataModelSeq => ArrayList<LogWriterConfig>.deserialize(data)
                case _ => throw Exception("日志输出器(writers)配置错误")
            },
            match (dms.get("loggers")) {
                case data: DataModelSeq => ArrayList<LoggerConfig>.deserialize(data)
                case _ => ArrayList<LoggerConfig>()
            },
            match (dms.get("converters")) {
                case data: DataModelSeq => ArrayList<ConverterConfig>.deserialize(data)
                case _ => ArrayList<ConverterConfig>()
            },
            get(dms, "pattern")
        )
        return result
    }
}

func getProperties(dms: DataModelStruct, ignoreKey: Array<String>) {
    let map = HashMap<String, String>()
    dms.getFields() |> filter<Field> {field => !ignoreKey.contains(field.getName())} |>
        forEach<Field> {
        field =>
        let d = (field.getData() as DataModelString)
        ifSome(d) {
            value => map.add(field.getName(), String.deserialize(value))
        }
    }
    return map
}

func get(dms: DataModelStruct, key: String, errorMsg: String) {
    match (dms.get(key)) {
        case data: DataModelString => String.deserialize(data)
        case _ => throw Exception(errorMsg)
    }
}

func get(dms: DataModelStruct, key: String) {
    match (dms.get(key)) {
        case data: DataModelString => String.deserialize(data)
        case _ => Option<String>.None
    }
}

func logLevel(level: String): LogLevel {
    match (level) {
        case "ERROR" => LogLevel.DEBUG
        case "WARN" => LogLevel.WARN
        case "INFO" => LogLevel.INFO
        case "DEBUG" => LogLevel.DEBUG
        case "TRACE" => LogLevel.TRACE
        case _ => throw Exception("level只能是ERROR,WARN,INFO,DEBUG,TRACE之一")
    }
}
