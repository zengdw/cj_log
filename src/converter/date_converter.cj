package cj_log.converter

public class DateConverter <: AbstractConverter {

  public func convert(record: LogRecord): String {
    let time = record.time
    let format = getFirstOption() ?? "yyyy-MM-dd HH:mm:ss"
    return time.format(format)
  }
 }