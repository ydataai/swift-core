import Foundation
import Vapor

public protocol InternalClient {
  var scheme: URI.Scheme { get }
  var host: String { get }
  var port: Int? { get }
  var basePath: String? { get }
  
  var httpClient: Vapor.Client { get }
  var logger: Logger { get }
  
  func send<Req: InternalRequest, Resp: Response>(_ request: Req) -> EventLoopFuture<Resp>
}

enum InternalClientError: Error {
  case encode(Error)
}

public extension InternalClient {
  var scheme: URI.Scheme { URI.Scheme("http") }
  var basePath: String? { nil }
  
  func send<Request: InternalRequest, R: Response>(_ request: Request) -> EventLoopFuture<R>
  where Request.Content: Encodable {
    
    var clientRequest = buildClientRequest(for: request)
    
    do {
      try request.content.flatMap { try clientRequest.content.encode($0, as: .json) }
    } catch {
      return httpClient.eventLoop.makeFailedFuture(InternalClientError.encode(error))
    }
    
    return httpClient.send(clientRequest)
      .always { self.logger.info("response for request \(clientRequest.url): \($0)") }
      .mapToInternalResponse()
  }
  
  func send<Request: InternalRequest, R: Response>(_ request: Request) -> EventLoopFuture<R> {
    
    let clientRequest = buildClientRequest(for: request)
    
    return httpClient.send(clientRequest)
      .always { self.logger.info("response for request \(clientRequest.url): \($0)") }
      .mapToInternalResponse()
  }
  
  func buildClientRequest<R: InternalRequest>(for request: R) -> ClientRequest {
    let path = basePath.flatMap { base in request.path.flatMap { "\(base)/\($0)" } ?? base } ?? request.path ?? ""
    
    let query = request.query.flatMap { queries in
      queries.compactMap { query -> String? in
        guard let value = query.value else { return nil }
        
        guard let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
          return nil
        }
        
        return String(format: "@%=@%", query.name, escapedValue)
      }.joined(separator: "&")
    }
    
    let url = URI(scheme: scheme, host: host, port: port, path: path, query: query)
    
    var clientRequest = ClientRequest()
    request.headers.flatMap { clientRequest.headers = .init($0.map { (key, value) in (key, value) }) }
    clientRequest.method = request.method
    clientRequest.url = url
    return clientRequest
  }
}

private extension EventLoopFuture where Value == ClientResponse {
  func mapToInternalResponse<R>() -> EventLoopFuture<R> where R: Response {
    return self.flatMapResult { response -> Result<R, Internal.ErrorResponse> in
      switch response.status.code {
      case (100..<400):
        return .success(R(headers: response.headers, status: response.status, body: response.body))
      default:
        do {
          let contentError = try response.content.decode(Internal.ServiceError.self)
          return .failure(Internal.ErrorResponse(headers: response.headers,
                                                 status: response.status,
                                                 message:contentError.message))
        } catch {
          return .failure(Internal.ErrorResponse(headers: [:],
                                                 status: .internalServerError,
                                                 message: "failed to decode response with error \(error)"))
        }
      }
    }
  }
}
