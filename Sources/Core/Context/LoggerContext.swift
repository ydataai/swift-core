import Foundation
import Logging

public protocol LoggerContext {
  var logger: Logger { get }
}
