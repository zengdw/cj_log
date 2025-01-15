package cj_log_framework.utils

import std.fs.{File, exists, OpenMode}
import encoding.json.{JsonValue, ToJson}
import cj_log_framework.config.LogConfig
import serialization.serialization.DataModel
import std.collection.ArrayList
import cj_log_framework.config.LogWriterConfig
import cj_log_framework.writer.{ConsoleWriter, Writer}

/**
 * 读取日志配置文件
 * @param filePath: 日志配置文件路径
 */
protected func readSettingFile(filePath: String): LogConfig {
    if (!exists(filePath)) {
        let writers = ArrayList<LogWriterConfig>()
        writers.add(LogWriterConfig("cj_log_framework.writer.ConsoleWriter", "consoleWriter", None))
        return LogConfig("INFO", writers, ArrayList())
    }
    let allBytes = File.readFrom(filePath)
    let setting = String.fromUtf8(allBytes)
    let jSetting = JsonValue.fromStr(setting)

    LogConfig.deserialize(DataModel.fromJson(jSetting))
}
