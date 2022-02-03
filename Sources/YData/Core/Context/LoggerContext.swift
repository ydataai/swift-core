import Foundation
import Vapor

public protocol LoggerContext {
  var logger: Logger { get }
}
