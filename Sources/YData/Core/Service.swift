import Foundation
import Vapor

public protocol Service {
  var context: ServiceContext { get }
}

public protocol ServiceContext {
  var eventLoop: EventLoop { get }
  var logger: Logger { get }
}
