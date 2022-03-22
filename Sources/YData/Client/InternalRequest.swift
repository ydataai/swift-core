import Vapor

public protocol InternalRequest {
  associatedtype Content
  
  var method: HTTPMethod { get }
  var path: String? { get }
  var headers: HTTPHeaders? { get }
  var query: [URLQueryItem]? { get }
  var content: Content? { get }
}

extension Internal {
  struct NoContentRequest: InternalRequest {
    typealias Content = Optional<Void>
    
    let method: HTTPMethod
    let path: String?
    let headers: HTTPHeaders?
    let query: [URLQueryItem]?
    let content: Content? = nil
    
    init(method: HTTPMethod,
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
    let method: HTTPMethod
    let path: String?
    let headers: HTTPHeaders?
    let query: [URLQueryItem]?
    let content: Content?
    
    init(method: HTTPMethod,
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
