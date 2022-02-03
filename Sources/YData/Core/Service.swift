import Foundation
import Vapor

public protocol ServiceContext: EventLoopContext, LoggerContext {}

public protocol Service {
  associatedtype Context: ServiceContext

  var context: Context { get }
}
