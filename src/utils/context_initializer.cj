package cj_log.utils

import cj_log.logger.LoggerContext

public class ContextInitializer {
    private var _defaultLoggerContext = LoggerContext()

    public static let SINGLETON = ContextInitializer()

    private init() {
        // TODO: 读取配置文件信息
    }

    public prop defaultLoggerContext: LoggerContext {
        get() {
            _defaultLoggerContext
        }
    }

}
