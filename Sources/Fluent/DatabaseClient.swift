import Foundation

public protocol DatabaseClient {
  var context: any DatabaseClientContext { get }
}
