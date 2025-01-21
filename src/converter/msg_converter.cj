package cj_log.converter

public class MsgConverter <: AbstractConverter {
  public func convert(record: LogRecord): String {
    return record.message
  }
}