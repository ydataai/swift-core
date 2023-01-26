import Foundation
import protocol NIOCore.EventLoop

public protocol EventLoopContext {
  var eventLoop: EventLoop { get }
}
