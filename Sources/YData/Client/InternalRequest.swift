import Vapor

public protocol InternalRequest {
  associatedtype Content
  
  var method: HTTPMethod { get }
  var path: String? { get }
  var headers: HTTPHeaders? { get }
  var query: [URLQueryItem]? { get }
  var content: Content? { get }
}

public extension Internal {
  struct NoContentRequest: InternalRequest {
    public typealias Content = Optional<Void>
    
    public let method: HTTPMethod
    public let path: String?
    public let headers: HTTPHeaders?
    public let query: [URLQueryItem]?
    public let content: Content? = nil
    
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
  
  struct ContentRequest<Content: Encodable>: InternalRequest {
    public let method: HTTPMethod
    public let path: String?
    public let headers: HTTPHeaders?
    public let query: [URLQueryItem]?
    public let content: Content?
    
    public init(method: HTTPMethod,
         path: String? = nil,
         headers: HTTPHeaders? = nil,
         query: [URLQueryItem]? = nil,
         content: Content? = nil) {
      self.method = method
      self.path = path
      self.headers = headers
      self.query = query
      self.content = content
    }
  }
}
