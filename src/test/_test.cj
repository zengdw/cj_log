package cj_log.test

import cj_log.macros.{LoggerFactroy, Log}
import std.regex.Regex
import std.unittest.testmacro.{Test, Tag}

@Log
class User {
    public func getName() {
        log.info("getName")
    }
}
@Test
func clssLog() {
    let user = User()
    user.getName()
}

@Test
@Log
func logTest() {
    log.info("logTest")
}

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
