package cj_log_framework.writer

import log.LogRecord

public interface Writer {
  func write(record: LogRecord): Unit
}