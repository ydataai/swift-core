import Vapor

public protocol InternalRequest {
  var method: HTTPMethod { get }
  var path: String? { get }
  var headers: HTTPHeaders? { get }
  var query: [URLQueryItem]? { get }
  var content: ContentContainer { get }
  var body: ByteBuffer? { get }
}

public extension Internal {
  struct ContentRequest: InternalRequest {
    public let method: HTTPMethod
    public let path: String?
    public var headers: HTTPHeaders?
    public let query: [URLQueryItem]?

    public var body: ByteBuffer?
    
    public init<C: Content>(method: HTTPMethod,
                            path: String? = nil,
                            headers: HTTPHeaders? = nil,
                            query: [URLQueryItem]? = nil,
                            content: C) throws {
      self.method = method
      self.path = path
      self.headers = headers
      self.query = query
      try self.content.encode(content)
    }

    public init(method: HTTPMethod,
                path: String? = nil,
                headers: HTTPHeaders? = nil,
                query: [URLQueryItem]? = nil) {
      self.method = method
      self.path = path
      self.headers = headers
      self.query = query
    }
  }
}

public extension Internal.ContentRequest {
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
      return _ContentContainer(body: self.body, headers: self.headers ?? [:])
    }
    set {
      let container = (newValue as! _ContentContainer)
      self.body = container.body
      self.headers += container.headers
    }
  }
}

extension Optional where Wrapped == HTTPHeaders {
  static func +=(left: inout Self, right: Wrapped) {
    if var left = left {
      left.add(contentsOf: right)
    }

    left = right
  }
}
