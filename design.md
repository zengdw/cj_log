# cj_log设计文档
## 介绍

cj_log是一个简单易用的仓颉日志框架,用于方便打印仓颉项目日志.使用@Log宏即可快速打印日志,通过json日志配置文件可自定义日志输出格式.通过反射的方式支持自定义logger writer converter组件.

### 项目特性

1. 支持打印日志到控制台和文件 
2. 支持json格式配置文件 
3. 支持日志打印添加自定义属性 
4. 日志打印自动添加所属文件和行号  
5. 支持设置每个包的日志打印级别 
6. 支持自定义日志输出格式  
7. 支持自定义writer,logger和converter

### 项目架构
```shell
└── src                                           #源码目录
    ├── config                                    #配置文件目录
    ├── converter                                 #默认转换器目录
    │   ├── abstract_converter.cj                 #抽象转换器,自定义转换器需继承该类
    │   ├── converter.cj
    ├── logger                                    #logger目录
    │   ├── abstract_logger.cj                    #抽象logger,自定义logger需继承该类
    │   ├── default_logger.cj                     #默认logger
    │   └── logger_factroy.cj                     #logger工厂.logger创建,配置文件读取
    ├── macros                                    #宏定义 
    │   └── log.cj                                #Log宏.引入宏可方便快捷的打印日志
    ├── test                                      #测试目录
    │   └── _test.cj
    ├── utils                                     #工具类
    │   ├── file_util.cj
    │   └── mdc.cj                                #MDC工具类,可添加线程级别的日志额外属性
    └── writer                                    #writer目录,日志输出方式          
        ├── abstract_writer.cj                    #抽象writer,自定义writer需继承该类
        └── writer.cj
```

### 日志配置
支持json格式配置文件,项目默认读取的配置文件路径为`./logSetting.json`.
配置示例:
```json
{
  "level": "INFO",    
  "pattern": "%{d(yyyy-MM-dd HH:mm:ss)} -%{5p} %{logger}:%{line} %{msg}",
  "writers": [
    {
      "writerClass": "cj_log.writer.FileWriter",
      "writerName": "fileWriter",
      "file": "./log/out.log"   // 输出日志文件路径
    },
    {
      "writerClass": "cj_log.writer.RollingFileWriter",
      "writerName": "rollingFileWriter",
      "file": "./log/rolling/out.log",    // 输出日志文件路径
      "maxFileSize": "20",   // 单个文件大小(M)
      "maxHistory": "30"     // 文件保留天数
    },
    {
      "writerClass": "cj_log.writer.ConsoleWriter",  // 输出日志到控制台
      "writerName": "consoleWriter"
    }
  ],
  "loggers": [
    {
      "level": "DEBUG",
      "loggerName": "cj_log.test.p",
      "writerNames": ["consoleWriter", "fileWriter"]
    }
  ],
  "converter": [
    {
      "converterKey": "",
      "converterClass": ""
    }
  ]
}
```
- `level`: 日志打印级别,支持所有日志级别配置
- `pattern`: 日志输出格式设置. 现默认实现的转换器有:
  - `%{d(yyyy-MM-dd HH:mm:ss)}`: 日期格式化.括号里面填写正确的日期时间格式化规则
  - `%{5p}`: 日志级别.前面数字(5)代表日志级别长度,正数表示前面添加空格( INFO),负数表示后面添加空格(INFO )
  - `%{logger}`: 日志所属文件名
  - `%{line}`: 日志所属文件行号
  - `%{msg}`: 日志内容
- `writers`: 日志输出方式配置
  - `writerClass`: writer类名
  - `writerName`: writer名称
  - 其余属性是特定于writerClass的
- `loggers`: logger配置
  - `level`: 当前logger的日志级别.未配置时`additivity=true`获取父logger的配置
  - `loggerName`: logger名称,填写包名
  - `additivity`: 是否继承父logger的配置,默认为true
  - `writerNames`: 当前logger打印日志时使用的writer,值只能是上面配置的writerName,可实现不同包的日志输出到不同的地方. 如果不配置且additivity=true,则使用默认writer. 
  - `loggerClass`: logger实现类,默认为`cj_log.logger.DefaultLogger`
- `converter`: 转换器配置.日志输出格式(`pattern`)里面可以使用自定义的转换器.
  - `converterKey`: 转换器key,用于在`pattern`中引用. 如`%{key}`
  - `converterClass`: 转换器实现类的全名称,如`cj_log.converter.DateConverter`

### 自定义logger,writer,converter
- logger
```cangjie
package cj_test.logger

import cj_log.logger.AbstractLogger
import cj_log.config.LoggerConfig   

class MyLogger <: AbstractLogger {
    public init() { // 必须要有无参构造函数
        
    }

    public func close() {
        if (closed.compareAndSwap(false, true)) {
            for (w in writers) {
                w.close()
            }
        }
    }

    public func log(record: LogRecord): Unit {
        super.log(record)
        if (!isClosed()) {
            for (w in writers) {
                w.write(record)
            }
        }
    }

    public func doBuild(properties: HashMap<String, String>): Unit{ 
        // logger 初始化逻辑
        // properties 是配置时添加的自定义属性 `prop1`, `prop2`
    }
}
```
使用方式:
```json
"loggers": [
    {
      "level": "DEBUG",
      "loggerName": "cj_log.test.p",
      "writerNames": ["consoleWriter", "fileWriter"],
      "loggerClass": "cj_test.logger.MyLogger",
      "prop1": "value1", // 自定义属性
      "prop2": "value2",
    }
]
```


- writer
```cangjie
package cj_test.writer

import cj_log.writer.AbstractWriter

public class MyWriter <: AbstractWriter {
    public init() { // 必须要有无参构造函数
        
    }

    public func write(record: LogRecord): Unit {
        
    }

    public func close() {
        
    }

    public func build(c: LogWriterConfig): Unit {
        this.pattern = c.pattern
        // c.properties 是配置时添加的自定义属性 `prop1`, `prop2`
    }
}
```
使用方式:
```json
"writers": [
    {
      "writerClass": "cj_test.writer.MyWriter", 
      "writerName": "myWriter",
      "prop1": "value1", // 自定义属性
      "prop2": "value2",
    }
]
```

- converter
```cangjie
package cj_test.converter

import cj_log.converter.AbstractConverter

public class MyConverter <: AbstractConverter {

  public func convert(record: LogRecord): String {
    // 获取第一个配置
    let firstOption = getFirstOption()  // = "5"
    // 获取所有配置
    let options = getOptionList() // = ["5", "p1", "p2"]
    // 获取X对应的值
    var X: String = ""
    for (attr in record.attrs) {
        if (attr[0] == "X") {
            X = match (attr[1]) {
                case s: String => s
                case i: Int64 => i.toString()
                case _ => ""
            }
            break
        }
    }
  }
 }
```
使用方式:
```json
{
    "pattern": "%{d(yyyy-MM-dd HH:mm:ss)} -%{5p}  %{5X(p1,p2)} %{logger}:%{line} %{msg}",
    "converter": [
        {
            "converterKey": "X",  // 转换器key,用于在`pattern`中引用,注意大小写统一
            "converterClass": "cj_test.converter.MyConverter"
        }
    ]
}
```
> 如果是不需要转换的日志属性,可在日志打印方法中添加额外的元组参数`log.info("xxx", ("prop1","value1"),("prop1","value1"))`,在pattern中可直接通过`%{prop1}`引用.如需添加整个线程通用的属性,可在方法中使用`MDC.put("prop1","value1")`添加,在当前线程之后的日志中都会包含`prop1`属性.