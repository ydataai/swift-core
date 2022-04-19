import Foundation

public protocol ServiceContext: EventLoopContext, LoggerContext {}

public protocol Service {
  associatedtype Context: ServiceContext

  var context: Context { get }
}
