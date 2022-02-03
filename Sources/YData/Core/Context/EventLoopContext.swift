import Foundation
import protocol NIO.EventLoop

public protocol EventLoopContext {
  var eventLoop: EventLoop { get }
}
