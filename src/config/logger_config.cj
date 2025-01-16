package cj_log_framework.config

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