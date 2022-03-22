import Vapor

public protocol Response: ResponseEncodable {
  var headers: HTTPHeaders { get set }
  var status: HTTPResponseStatus { get }
  var body: ByteBuffer? { get set }
  
  var content: ContentContainer { get set }
  
  init(headers: HTTPHeaders, status: HTTPResponseStatus, body: ByteBuffer?)
}

extension Response {
  func encodeResponse(for request: Request) -> EventLoopFuture<Vapor.Response> {
    let response = Vapor.Response(status: status, headers: headers)
    response.body ?= body.flatMap(Vapor.Response.Body.init)
    return request.eventLoop.makeSucceededFuture(response)
  }
}

extension Response {
  @inlinable
  func map<NewValue>(_ callback: (ContentContainer) throws -> (NewValue)) throws -> Self where NewValue: Content {
    let newValue = try callback(content)
    
    var newResponse = Self.init(headers: headers, status: status, body: nil)
    try newResponse.content.encode(newValue)
    
    return newResponse
  }
  
  @inlinable
  func map(_ callback: (ContentContainer) throws -> (Void)) throws -> Self {
    let _ = try callback(content)
    
    return Self.init(headers: headers, status: status, body: nil)
  }
}

extension EventLoopFuture where Value: Response {
  func mapContent<NewValue>(_ callback: @escaping (ContentContainer) throws -> (NewValue))
  -> EventLoopFuture<Value> where NewValue: Content { flatMapThrowing { try $0.map(callback) } }
  
  func flatMapContentThrowing<NewValue>(_ callback: @escaping (ContentContainer) throws -> (NewValue))
  -> EventLoopFuture<NewValue> { flatMapThrowing { try callback($0.content) } }
  
  func flatMapContentResult<NewValue, E>(_ callback: @escaping (ContentContainer) -> Result<NewValue, E>)
  -> EventLoopFuture<NewValue> where NewValue: Content, E: Error { flatMapResult { callback($0.content) } }
}
