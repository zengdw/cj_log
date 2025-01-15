package cj_log_framework.test

import cj_log_framework.macros.{LoggerFactroy, Log}
import std.regex.Regex
import std.unittest.testmacro.{Test, Tag}

@Log
class User {
    public func getName() {
        log.info("getName")
    }
}

@Test
@Log
func logTest() {
    log.info("logTest")
}

@Test
func clssLog() {
    let user = User()
    user.getName()
}

@Test
@Tag[patternTest]
@Log
func patternTest() {
    let DEFAULT_PATTERN: String = "%{d(yyyy-MM-dd HH:mm:ss)} -%{5p} %{logger}:%{line} %{msg}"
    let r = Regex("%\\{(.*?+)\\}").matcher(DEFAULT_PATTERN)
    while (true) {
        let matchData = r.find()
        match (matchData) {
            case Some(md) =>
                log.info(md.matchStr(1))
            case None => break
        }
    }
}
