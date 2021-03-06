import Vapor

public protocol InternalResponse {
  var headers: HTTPHeaders { get set }
  var status: HTTPResponseStatus { get }
  var body: ByteBuffer? { get set }

  var content: ContentContainer { get set }

  init(headers: HTTPHeaders, status: HTTPResponseStatus, body: ByteBuffer?)
}

public extension InternalResponse {
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

public extension Internal {
  struct ErrorResponse: Error {
    public let headers: HTTPHeaders
    public let status: HTTPResponseStatus
    public let message: String
  }
  
  struct SuccessResponse: InternalResponse {
    public var headers: HTTPHeaders
    public let status: HTTPResponseStatus
    public var body: ByteBuffer?
    
    public init(headers: HTTPHeaders, status: HTTPResponseStatus, body: ByteBuffer?) {
      self.headers = headers
      self.status = status
      self.body = body
    }
  }
}

extension Internal.ErrorResponse: AbortError {
  public var reason: String { message }
}

public extension Internal.SuccessResponse {
  private struct _ContentContainer: ContentContainer {
    var body: ByteBuffer?
    var headers: HTTPHeaders
    
    var contentType: HTTPMediaType? { headers.contentType }
    
    func decode<D>(_ decodable: D.Type, using decoder: ContentDecoder) throws -> D where D : Decodable {
      guard let body = self.body else {
        throw Abort(.lengthRequired)
      }
      return try decoder.decode(D.self, from: body, headers: self.headers)
    }
    
    mutating func encode<E>(_ encodable: E, using encoder: ContentEncoder) throws where E : Encodable {
      var body = ByteBufferAllocator().buffer(capacity: 0)
      try encoder.encode(encodable, to: &body, headers: &self.headers)
      self.body = body
    }
  }
  
  var content: ContentContainer {
    get {
      return _ContentContainer(body: self.body, headers: self.headers)
    }
    set {
      let container = (newValue as! _ContentContainer)
      self.body = container.body
      self.headers = container.headers
    }
  }
}
