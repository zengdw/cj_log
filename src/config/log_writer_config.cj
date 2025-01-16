package cj_log_framework.config

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