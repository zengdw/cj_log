package cj_log_framework.converter

public class MsgConverter <: AbstactConverter {
  public func convert(record: LogRecord): String {
    return record.message
  }
}