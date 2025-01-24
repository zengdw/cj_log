package cj_log.utils

import std.collection.HashMap

public class MDC {
    private static let threadLocalMap = ThreadLocal<HashMap<String, String>>() /* cjlint-ignore !G.NAM.05 */

    public static func put(key: String, value: String): Unit {
        let map = threadLocalMap.get()
        if (let Some(m) <- map) {
            m.add(key, value)
        } else {
            let m = HashMap<String, String>()
            m.add(key, value)
            threadLocalMap.set(m)
        }
    }

    public static func localMap() {
        threadLocalMap.get() ?? HashMap<String, String>()
    }

    public static func putAll(map: HashMap<String, String>): Unit {
        let _map = threadLocalMap.get()
        if (let Some(m) <- _map) {
            m.add(all: map)
        } else {
            threadLocalMap.set(map)
        }
    }
}