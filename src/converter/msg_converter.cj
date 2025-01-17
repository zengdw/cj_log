package cj_log.converter

public class MsgConverter <: AbstactConverter {
  public func convert(record: LogRecord): String {
    return record.message
  }
}