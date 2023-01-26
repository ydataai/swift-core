import Foundation
import Vapor

public extension InternalClient {
  func send<Request: InternalRequest, Response: InternalResponse>(_ request: Request) async throws -> Response {
    try await send(request).get()
  }

  func send<Request: InternalRequest, C: Decodable>(_ request: Request) async throws -> C {
    try await (send(request) as EventLoopFuture<ClientResponse>).get().mapToModel()
  }
}
