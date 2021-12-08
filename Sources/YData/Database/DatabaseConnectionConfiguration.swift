import Fluent
import Foundation

protocol DatabaseConnectionConfiguration {
  var factory: DatabaseConfigurationFactory { get }
}
