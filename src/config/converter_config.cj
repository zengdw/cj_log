package cj_log_framework.config

public class ConverterConfig <: Serializable<ConverterConfig> {
    private var _converterKey: String
    private var _converterClass: String

    public init(converterKey: String, converterClass: String) {
        this._converterKey = converterKey
        this._converterClass = converterClass
    }

    public prop converterKey: String {
        get() {
            this._converterKey
        }
    }
    public prop converterClass: String {
        get() {
            this._converterClass
        }
    }

    public func serialize() {
        DataModelStruct().add(field("converterKey", converterKey)).add(field("converterClass", converterClass))
    }

    public static func deserialize(dataModel: DataModel) {
        if (let Some(dms) <- (dataModel as DataModelStruct)) {
            return ConverterConfig(
                String.deserialize(dms.get("converterKey")),
                String.deserialize(dms.get("converterClass")),
            )
        }
        throw Exception("this data is not DataModelStruct")
    }
}
