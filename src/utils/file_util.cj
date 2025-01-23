package cj_log.utils

import std.fs.{File, exists, OpenMode}
import encoding.json.{JsonValue, ToJson}
import cj_log.config.LogConfig
import serialization.serialization.DataModel
import std.collection.{ArrayList, HashMap}
import cj_log.config.LogWriterConfig

/**
 * 读取日志配置文件
 * @param filePath: 日志配置文件路径
 */
protected func readSettingFile(filePath: String): ?LogConfig {
    if (!exists(filePath)) {
        return None
    }
    let allBytes = File.readFrom(filePath)
    let setting = String.fromUtf8(allBytes)
    let jSetting = JsonValue.fromStr(setting)

    LogConfig.deserialize(DataModel.fromJson(jSetting))
}
