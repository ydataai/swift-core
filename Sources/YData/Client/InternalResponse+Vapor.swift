import Foundation
import Vapor

public extension ResponseEncodable where Self: Response {
  func encodeResponse(for request: Request) -> EventLoopFuture<Vapor.Response> {
    let response = Vapor.Response(status: status, headers: headers)
    response.body ?= body.flatMap(Vapor.Response.Body.init)
    return request.eventLoop.makeSucceededFuture(response)
  }
}

public extension EventLoopFuture where Value: InternalResponse {
  func mapContent<NewValue>(_ callback: @escaping (ContentContainer) throws -> (NewValue))
  -> EventLoopFuture<Value> where NewValue: Content { flatMapThrowing { try $0.map(callback) } }

  func flatMapContentThrowing<NewValue>(_ callback: @escaping (ContentContainer) throws -> (NewValue))
  -> EventLoopFuture<NewValue> { flatMapThrowing { try callback($0.content) } }

  func flatMapContentResult<NewValue, E>(_ callback: @escaping (ContentContainer) -> Result<NewValue, E>)
  -> EventLoopFuture<NewValue> where NewValue: Content, E: Error { flatMapResult { callback($0.content) } }
}

public extension ClientResponse: InternalResponse {
  public init(headers: HTTPHeaders, status: HTTPResponseStatus, body: ByteBuffer?) {
    self.init(status: status, headers: headers, body: body)
  }

  @inlinable
  func map<NewValue>(_ callback: (Content) throws -> (NewValue)) throws -> Self where NewValue: Codable {
    guard let content = content else {
      return self
    }

    let newValue = try callback(content)

    var newResponse = Self.init(headers: headers, status: status, body: nil)
    try newResponse.content.encode(newValue)

    return newResponse
  }
}

