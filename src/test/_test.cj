package cj_log.test

import std.regex.Regex
import std.unittest.testmacro.{Test, Tag}
import std.collection.ArrayList
import cj_log.macros.{LoggerFactroy, Log}

@Test
@Tag[patternTest]
@Log
func patternTest() {
    let DEFAULT_PATTERN: String = "%{d(yyyy-MM-dd HH:mm:ss)} -%{5p} %{logger}:%{line} %{msg}"
    let r = Regex(#"%\{(\d*)([a-z]+)(?:\(([^)]*)\))?\}"#).matcher(DEFAULT_PATTERN)
    let matchData = r.findAll()
    if (let Some(arr) <- matchData) {
        log.info("matchData size : ${arr.size}")
        for (md in arr) {
            log.info("groupNum : ${md.groupNumber()}")
            log.info(md.matchStr(0))
            for (i in 1..=md.groupNumber()) {
                log.info(md.matchStr(i))
            }
        }
    }
}

/**
 * 测试日志自定义属性
 */
@Test
@Tag[testProp]
@Log
func testProp() {
    log.info("testProp", ("testProp", "testProp"))
}