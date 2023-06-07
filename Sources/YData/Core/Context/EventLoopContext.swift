import Foundation
import protocol NIO.EventLoop

public protocol EventLoopContext: Context {
  var eventLoop: EventLoop { get }
}
