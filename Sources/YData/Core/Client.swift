import Foundation

public protocol ClientContext: EventLoopContext, LoggerContext {}

public protocol Client {
  associatedtype Context: ClientContext

  var context: Context { get }
}
