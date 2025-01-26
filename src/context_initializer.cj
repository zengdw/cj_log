package cj_log

import std.process.Process
import std.collection.ArrayList
import serialization.serialization.DataModel
import encoding.json.{JsonValue, ToJson}
import std.sync.ReentrantMutex
import cj_log.logger.LoggerContext
import cj_log.utils.readSettingFile
import cj_log.writer.createWriters
import cj_log.config.LogConfig
import cj_log.converter.converterConfigHandle

public class ContextInitializer {
    private let DEFAULT_CONFIG_PATH = "./logSetting.json"
    private let DEFAULT_CONFIG = """
            {
                "level": "INFO",
                "writerNames": ["consoleWriter"],
                "writers": [
                    {
                        "writerClass": "cj_log.writer.ConsoleWriter",
                        "writerName": "consoleWriter"
                    }
                ]
            }
            """

    private var _defaultLoggerContext: LoggerContext
    private static var instance: ?ContextInitializer = None
    private static let MTX = ReentrantMutex()

    public static func getInstance(): ContextInitializer {
        if (let Some(i) <- instance) {
            return i
        }
        synchronized(MTX) {
            if (let Some(i) <- instance) {
                return i
            }
            let ci = ContextInitializer()
            instance = ci
            return ci
        }
    }

    private init() {
        // 读取配置文件信息
        let logSetting = Process.current.getEnv("CJ_LOG_SETTING") ?? DEFAULT_CONFIG_PATH
        let logConfigOp = readSettingFile(logSetting)
        var logConfig = match (logConfigOp) {
            case Some(config) => config
            case None =>
                println("cj_log: No profile found, default configuration used")
                LogConfig.deserialize(DataModel.fromJson(JsonValue.fromStr(DEFAULT_CONFIG)))
        }

        let writerMap = createWriters(logConfig.writers, logConfig.pattern)
        converterConfigHandle(logConfig.converters)
        _defaultLoggerContext = LoggerContext(logConfig, writerMap)
    }

    public prop defaultLoggerContext: LoggerContext {
        get() {
            _defaultLoggerContext
        }
    }
}
