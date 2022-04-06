import Foundation
import Vapor

public extension Client {
  func send<Request: ClientRequest, Resp: Response>(_ request: Request) async throws -> Resp
  where Request.Content: Encodable {
    return try await self.send(request).get()
  }

  func send<Request: ClientRequest, Resp: Response>(_ request: Request) async throws -> Resp {
    return try await self.send(request).get()
  }

  func send<Request: ClientRequest, Resp: Model>(_ request: Request) async throws -> Resp
  where Request.Content: Encodable {
    try await (send(request) as EventLoopFuture<ClientResponse>).get().mapToModel()
  }

  func send<Request: ClientRequest, Resp: Model>(_ request: Request) async throws -> Resp {
    try await (send(request) as EventLoopFuture<ClientResponse>).get().mapToModel()
  }
}

private extension ClientResponse  {
  func mapToModel<R>() async throws -> R where R: Model {
    switch status.code {
    case (100..<400):
      do {
        return try content.decode(R.self)
      } catch {
        throw Internal.ErrorResponse(headers: [:],
                                     status: .internalServerError,
                                     message: "failed to decode response \(error)")
      }
    default:
      do {
        let contentError = try content.decode(Internal.ServiceError.self)
        throw Internal.ErrorResponse(headers: headers,
                                     status: status,
                                     message:contentError.message)
      } catch {
        throw Internal.ErrorResponse(headers: [:],
                                     status: .internalServerError,
                                     message: "failed to decode response with error \(error)")
      }
    }
  }
}

