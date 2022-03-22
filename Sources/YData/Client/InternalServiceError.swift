import Foundation
import Vapor

extension Internal {
  struct ServiceError: Decodable {
    let message: String
  }
}
