package cj_log_framework.config

import log.LogLevel
import std.collection.{ArrayList, HashMap, forEach, filter}
import serialization.serialization.{Serializable, DataModelStruct, DataModel, field, DataModelString, DataModelSeq, 
    DataModelBool, Field}

public class LogConfig <: Serializable<LogConfig> {
    public let level: LogLevel

    public LogConfig(
        level: String,
        public let writers: ArrayList<LogWriterConfig>,
        public let loggers: ArrayList<LoggerConfig>
    ) {
        this.level = logLevel(level)
    }

    public func serialize(): DataModel {
        return DataModelStruct()
            .add(field("level", level.name))
            .add(field("writers", writers))
            .add(field("loggers", loggers))
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
            }
        )
        return result
    }
}

public class LoggerConfig <: Serializable<LoggerConfig> {
    public let level: ?LogLevel

    public LoggerConfig(
        level: ?String,
        public let loggerName: String,
        public let loggerClass: String,
        public let writerNames: ArrayList<String>,
        public let properties: HashMap<String, String>,
        public let additivity!: Bool = true
    ) {
        this.level = match (level) {
            case Some(l) => logLevel(l)
            case None => None
        }
    }

    public func serialize(): DataModel {
        return DataModelStruct()
            .add(field("level", level?.name))
            .add(field("loggerName", loggerName))
            .add(field("writerNames", writerNames))
            .add(field("additivity", additivity))
            .add(field("loggerClass", loggerClass))
            .add(field("properties", properties))
    }

    public static func deserialize(dm: DataModel): LoggerConfig {
        let dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let ignoreKey = ["level", "additivity", "loggerClass", "writerNames", "loggerName"]
        let result = LoggerConfig(
            get(dms, "level"),
            get(dms, "loggerName", "日志设置异常,loggerName未设置"),
            get(dms, "loggerClass", "日志设置异常,loggerClass未设置"),
            match (dms.get("writerNames")) {
                case data: DataModelSeq => ArrayList.deserialize(data)
                case _ => ArrayList()
            },
            getProperties(dms, ignoreKey),
            additivity: match (dms.get("additivity")) {
                case data: DataModelBool => Bool.deserialize(data)
                case _ => true
            },
        )
        return result
    }
}

public class LogWriterConfig <: Serializable<LogWriterConfig> {
    public LogWriterConfig(
        public let writerClass: String,
        public let writerName: String,
        public let properties: HashMap<String, String>
    ) {
    }

    public func serialize(): DataModel {
        let dms = DataModelStruct().add(field("writerClass", writerClass)).add(field("writerName", writerName))
        ifSome(properties) {
            property => property |> forEach<(String, String)> {
                p => dms.add(field(p[0], p[1]))
            }
        }
        return dms
    }

    public static func deserialize(dm: DataModel): LogWriterConfig {
        let dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let result = LogWriterConfig(
            get(dms, "writerClass", "日志配置异常,writerClass未设置"),
            get(dms, "writerName", "日志配置异常,writerName未设置"),
            getProperties(dms, "writerClass", "writerName")
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
