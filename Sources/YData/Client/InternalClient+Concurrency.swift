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

public extension EventLoopFuture where Value: InternalResponse {
  func mapToContent<R>() -> EventLoopFuture<R> where R: Decodable {
    flatMapThrowing { response -> R in try response.content.decode(R.self)
    }
  }
}

extension ClientResponse: InternalResponse {
  public init(headers: HTTPHeaders, status: HTTPResponseStatus, body: ByteBuffer?) {
    self.init(status: status, headers: headers, body: body)
  }

  @inlinable
  func map<NewValue>(_ callback: (ContentContainer) throws -> (NewValue)) throws -> Self where NewValue: Content {
    let newValue = try callback(content)

    var newResponse = Self.init(headers: headers, status: status, body: nil)
    try newResponse.content.encode(newValue)

    return newResponse
  }
}

public extension ClientResponse  {
  func mapToModel<C>() throws -> C where C: Decodable {
    switch status.code {
    case (100..<400):

      do {
        return try content.decode(C.self)
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

extension Internal.Client {
  enum Error: Swift.Error {
    case missingContent
  }
}
