# cj_log - 仓颉日志框架
cj_log是一个简单易用的仓颉日志框架，用于方便打印仓颉项目日志。使用@Log宏即可快速打印日志，可通过自定义writer和logger实现自定义日志输出。
## Feature
1. 支持打印日志到控制台和文件  ✔
2. 支持json格式配置文件  ✔
3. 支持日志打印添加自定义属性  ✔
4. 日志打印自动添加所属文件和行号   ✔
5. 支持设置日志文件大小，日志文件保留时间   ✔
6. 支持设置每个包的日志打印级别   ✔
7. 支持自定义日志输出格式   ✔
8. 支持自定义writer和logger  ✔
## Usage
1. 引入cj_log库
2. 配置json格式配置文件，也可不添加配置文件，默认输出INFO级别的日志到控制台。[配置模板](./logSetting.json)
3. 在文件引入包`import cj_log.macros.{LoggerFactroy, Log}`
4. 在类或方法上添加`@Log`宏
5. 使用`log.(info|debug|warn|error|fatal)`打印日志，可在方法中添加自定义属性，如`log.info("hello", ("prop1", "cj"), ("prop2", "cj"))`
   ```
   package p

   import cj_log.macros.{LoggerFactroy, Log}

   @Log
   class C {
      func f() {
        log.info("hello", ("prop1", "cj"), ("prop2", "cj"))
      }
   }

   @Log
   func f1() {
      log.debug("hello", ("prop1", "cj"), ("prop2", "cj"))
   }

   @Log
   func main() {
      log.error("hello", ("prop1", "cj"), ("prop2", "cj"))
   }
   ```