package cj_log.logger

public class DefaultLogger <: AbstractLogger {

    public func close() {
        if (closed.compareAndSwap(false, true)) {
            for (w in writers) {
                w.close()
            }
        }
    }

    public func log(record: LogRecord): Unit {
        if (!isClosed()) {
            let attrs = attrs.toArray().concat(record.attrs)
            record.attrs = attrs
            for (w in writers) {
                w.write(record)
            }
        }
    }

    public func doBuild(properties: HashMap<String, String>): Unit{ /* cjlint-ignore !G.FUN.02 */

    }
}
