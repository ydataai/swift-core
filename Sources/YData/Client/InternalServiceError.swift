import Foundation
import Vapor

public extension Internal {
  struct ServiceError: Decodable {
    let message: String
  }
}
