<div align="center">
<h1>cj_log</h1>
</div>

<p align="center">
<img alt="" src="https://img.shields.io/badge/release-v0.0.1-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjc-v0.58.3-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/cjcov-0.0%25-brightgreen" style="display: inline-block;" />
<img alt="" src="https://img.shields.io/badge/project-open-brightgreen" style="display: inline-block;" />
</p>

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

## 项目架构

详见[设计文档](./design.md)

### 源码目录

```shell
├── LICENSE
├── README.md                                     #整体介绍
├── cjpm.toml
├── logSetting.json                               #日志配置文件模板
└── src                                           #源码目录
    ├── config                                    #配置文件目录
    │   ├── converter_config.cj                   #转换器配置文件
    │   ├── log_config.cj                         #日志配置文件
    │   ├── log_writer_config.cj                  #writer配置文件
    │   └── logger_config.cj                      #logger配置文件
    ├── converter                                 #默认转换器目录
    │   ├── abstract_converter.cj                 #抽象转换器,自定义转换器需继承该类
    │   ├── converter.cj
    │   ├── date_converter.cj
    │   ├── default_converter.cj
    │   ├── level_converter.cj
    │   ├── line_converter.cj
    │   ├── logger_converter.cj
    │   └── msg_converter.cj
    ├── import.cj
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
        ├── console_writer.cj                     #输出日志到控制台
        ├── file_writer.cj                        #输出日志到文件
        └── writer.cj
```

## 使用说明
### 编译构建

描述具体的编译过程：

```shell
cpm update
cpm build
```

### 功能示例
#### 打印日志功能示例

功能示例描述: 
在顶级方法或类方法中打印日志,有2中使用方法，一是使用`@Log`宏，二是`let log = LoggerFactroy.createLogger("loggerName")`.推荐使用`@Log`宏的方式,`@Log`会自动在方法或class上添加log变量，并在打印日志时自动添加所属文件和行号。系统默认打印INFO级别的日志到控制台,可使用配置文件自定义日志打印方式.[日志模板](./logSetting.json)

示例代码如下：

```cangjie
package log_test

import cj_log.macros.{LoggerFactroy, Log}

@Log
class Test {
    func test() {
        log.info("xxxx")
    }
}

@Log
func test() {
    log.info("xxxx")
}

@Log
main() {
    log.info("xxxx")
}
```

执行结果如下：

```shell
2025-01-20 16:47:15 - INFO 123 cj_log.test._test.cj:44 testProp
2025-01-20 16:47:15 - INFO 123 cj_log.test._test.cj:45 testProp222
2025-01-21 11:28:46 - INFO 123 cj_log.test._test.cj:44 testProp
2025-01-21 11:28:46 - INFO 123 cj_log.test._test.cj:45 testProp222
```

## 约束与限制
描述环境限制，版本限制，依赖版本等

## 开源协议
[Apache License 2.0](./LICENSE)

## 参与贡献

欢迎给我们提交PR，欢迎给我们提交Issue，欢迎参与任何形式的贡献。