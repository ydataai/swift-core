import Foundation
import Vapor

public protocol LoggerContext: Context {
  var logger: Logger { get }
}
