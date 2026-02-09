import Fluent
import Foundation

protocol DatabaseConnectionConfiguration: Sendable {
  var factory: DatabaseConfigurationFactory { get }
}
