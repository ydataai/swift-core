import Foundation
import Vapor

extension ResponseEncodable where Self: InternalResponse {
  func encodeResponse(for request: Request) -> EventLoopFuture<Vapor.Response> {
    let response = Vapor.Response(status: status, headers: headers)
    response.body ?= body.flatMap(Vapor.Response.Body.init)
    return request.eventLoop.makeSucceededFuture(response)
  }
}

public extension EventLoopFuture where Value: InternalResponse {
//  func mapContent<NewValue>(_ callback: @escaping (ContentContainer) throws -> (NewValue))
//  -> EventLoopFuture<Value> where NewValue: Content {
//    flatMapThrowing { try $0.map(callback) }
//  }

  func mapToContent<R>() -> EventLoopFuture<R> where R: Decodable {
    flatMapThrowing { response -> R in try response.content.decode(R.self) }
  }

  func flatMapContentThrowing<NewValue>(_ callback: @escaping (ContentContainer) throws -> (NewValue))
  -> EventLoopFuture<NewValue> { flatMapThrowing { try callback($0.content) } }

  func flatMapContentResult<NewValue, E>(_ callback: @escaping (ContentContainer) -> Result<NewValue, E>)
  -> EventLoopFuture<NewValue> where NewValue: Content, E: Error { flatMapResult { callback($0.content) } }
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
