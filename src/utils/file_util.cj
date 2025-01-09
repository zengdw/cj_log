package cj_log_framework.utils

import std.fs.{File, exists, OpenMode}
import encoding.json.{JsonValue, ToJson}
import cj_log_framework.config.LogConfig
import serialization.serialization.DataModel

/*
    读取日志配置文件
    @param filePath: 日志配置文件路径
 */
protected func readSettingFile(filePath: String): LogConfig {
    if (!exists(filePath)) {
        println("日志配置文件不存在，使用默认配置")
    }
    let allBytes = File.readFrom(filePath)
    let setting = String.fromUtf8(allBytes)
    let jSetting = JsonValue.fromStr(setting)

    LogConfig.deserialize(DataModel.fromJson(jSetting))
}
