package cj_log_framework.config

import log.LogLevel
import std.collection.ArrayList
import serialization.serialization.{Serializable, DataModelStruct, DataModel, field, DataModelString, DataModelSeq, 
    DataModelBool}

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
            get(dms, "level", "INFO"),
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
        public let logger: String,
        public let loggerClass: ?String,
        public let writers: ArrayList<String>,
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
            .add(field("logger", logger))
            .add(field("writers", writers))
            .add(field("additivity", additivity))
            .add(field("loggerClass", loggerClass))
    }

    public static func deserialize(dm: DataModel): LoggerConfig {
        let dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let result = LoggerConfig(
            get(dms, "level"),
            get(dms, "loggerClass", ""),
            get(dms, "logger", ""),
            match (dms.get("writers")) {
                case data: DataModelSeq => ArrayList.deserialize(data)
                case _ => ArrayList()
            },
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
        public let filePath: ?String,
        public let writerClass: ?String,
        public let fileName: ?String,
        public let pattern: ?String,
        public let name: ?String
    ) {
    }

    public func serialize(): DataModel {
        return DataModelStruct()
            .add(field("filePath", filePath))
            .add(field("writerClass", writerClass))
            .add(field("fileName", fileName))
            .add(field("pattern", pattern))
            .add(field("name", name))
    }

    public static func deserialize(dm: DataModel): LogWriterConfig {
        let dms = match (dm) {
            case data: DataModelStruct => data
            case _ => throw Exception("this data is not DataModelStruct")
        }
        let result = LogWriterConfig(
            get(dms, "filePath"),
            get(dms, "writerClass"),
            get(dms, "fileName"),
            get(dms, "pattern"),
            get(dms, "name")
        )
        return result
    }
}

func get(dms: DataModelStruct, key: String) {
    match (dms.get(key)) {
        case data: DataModelString => String.deserialize(data)
        case _ => Option<String>.None
    }
}

func get(dms: DataModelStruct, key: String, default: String) {
    match (dms.get(key)) {
        case data: DataModelString => String.deserialize(data)
        case _ => default
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
