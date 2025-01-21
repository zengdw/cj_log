package cj_log.converter

public class DefaultConverter <: AbstractConverter {
    private var propName: String

    public init(propName: String) {
        this.propName = propName
    }

    public func convert(record: LogRecord) {
        var propValue: String = ""
        for (attr in record.attrs) {
            if (attr[0] == propName) {
                propValue = match (attr[1]) {
                    case s: String => s
                    case i: Int64 => i.toString()
                    case _ => ""
                }
                break
            }
        }
        return propValue
    }
}
