import Foundation

public protocol DatabaseClient {
  associatedtype Context: DatabaseClientContext
  
  var context: Context { get }
}
