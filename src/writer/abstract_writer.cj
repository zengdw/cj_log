package cj_log.writer

import std.regex.{Regex, Matcher}
import std.collection.{HashMap, ArrayList}
import log.LogRecord
import cj_log.converter.createConverter

public abstract class AbstractWriter <: Writer {
    let DEFAULT_PATTERN: String = "%{d(yyyy-MM-dd HH:mm:ss)} -%{5p} %{logger}:%{line} %{msg}"
    var pattern: ?String = None
    let r = Regex(#"%\{(\d*)([a-zA-Z0-9_]+)(?:\(([^)]*)\))?\}"#)

    public func logFormat(record: LogRecord): String {
        var p = pattern ?? DEFAULT_PATTERN
        var matcher = r.matcher(p)
        let matchData = matcher.findAll()

        if (let Some(arr) <- matchData) {
            for (md in arr) {
                let optionList = ArrayList<String>()
                let num = md.groupNumber()
                optionList.add(all: md.matchStr(1).split(",", removeEmpty: true))
                if (num == 3) {
                    optionList.add(all: md.matchStr(3).split(",", removeEmpty: true))
                }
                let fragment = md.matchStr()
                let converter = createConverter(md.matchStr(2), fragment, optionList)
                let str = converter.convert(record)
                p = p.replace(fragment, str)
            }
            return p + "\n"
        } else {
            println("日志pattern配置错误")
            return ""
        }
    }
}