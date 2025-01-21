package cj_log.converter

public class LineConverter <: AbstractConverter {
    public func convert(record: LogRecord): String {
        var line: String = ""
        for (attr in record.attrs) {
            if (attr[0] == "line") {
                line = match (attr[1]) {
                    case s: String => s
                    case i: Int64 => i.toString()
                    case _ => ""
                }
                break
            }
        }
        return line
    }
}
