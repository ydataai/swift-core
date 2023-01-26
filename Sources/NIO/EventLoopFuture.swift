import NIOCore

extension EventLoopFuture {
  public func delay(_ timeAmount: TimeAmount, _ task: @escaping () -> EventLoopFuture<Value>)
  -> EventLoopFuture<Value> {
    eventLoop.flatScheduleTask(in: timeAmount, task).futureResult
  }

  // public func mapAlways<NewValue>(
  //   file: StaticString = #file,
  //   line: UInt = #line,
  //   _ callback: @escaping (Result<Value, Error>) -> Result<NewValue, Error>
  // ) -> EventLoopFuture<NewValue> {

  //   self.flatMapAlways { self.eventLoop.makeCompletedFuture(callback($0)) }
  // }
}
