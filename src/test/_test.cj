package cj_log_framework.test

import cj_log_framework.macros.{LoggerFactroy, Log}


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