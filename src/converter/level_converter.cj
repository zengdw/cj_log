package cj_log.converter

import std.convert.Parsable

public class LevelConverter <: AbstractConverter {
    public func convert(record: LogRecord): String {
        let firstOption = getFirstOption()
        if (let Some(len) <- firstOption) {
            let l = Int64.parse(len)
            if (l > 0) {
                return record.level.name.padStart(l)
            } else {
                return record.level.name.padEnd(-l)
            }
        } else {
            return record.level.name
        }
    }
}
