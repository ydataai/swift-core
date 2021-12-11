import Foundation
import Vapor

public protocol ServiceContext {
  var eventLoop: EventLoop { get }
  var logger: Logger { get }
}

public protocol Service {
  associatedtype Context: ServiceContext

  var context: Context { get }
}
