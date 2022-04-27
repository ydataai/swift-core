import Foundation
import Vapor

public extension Internal {
  enum Client {}
}

public protocol InternalClient {
  var scheme: URI.Scheme { get }
  var host: String { get }
  var port: Int? { get }
  var basePath: String? { get }
  
  var httpClient: Vapor.Client { get }
  var logger: Logger { get }
}

public enum InternalClientError: Error {
  case encode(Error)
}

public extension InternalClient {
  var scheme: URI.Scheme { URI.Scheme("http") }
  var basePath: String? { nil }
  
  func send<Request: InternalRequest, Response: InternalResponse>(_ request: Request) -> EventLoopFuture<Response> {
    let clientRequest = buildClientRequest(for: request)
    
    return httpClient.send(buildClientRequest(for: request))
      .always { self.logger.info("response for request \(clientRequest.url): \($0)") }
      .mapToInternalResponse()
  }
  
  internal func buildClientRequest<R: InternalRequest>(for request: R) -> ClientRequest {
    let path = basePath.flatMap { base in request.path.flatMap { "\(base)/\($0)" } ?? base } ?? request.path ?? ""
    
    let query = request.query.flatMap { queries in
      queries.compactMap { query -> String? in
        guard let value = query.value else { return nil }
        
        guard let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
          return nil
        }
        
        return "\(query.name)=\(escapedValue)"
      }.joined(separator: "&")
    }
    
    let url = URI(scheme: scheme, host: host, port: port, path: path, query: query)
    
    var clientRequest = ClientRequest()
    request.headers.flatMap { clientRequest.headers = .init($0.map { (key, value) in (key, value) }) }
    clientRequest.method = request.method
    clientRequest.url = url
    clientRequest.body = request.body
    return clientRequest
  }
}

private extension EventLoopFuture where Value: InternalResponse {
  func mapToInternalResponse<R>() -> EventLoopFuture<R> where R: InternalResponse {
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
        } catch DecodingError.keyNotFound {
          let contentError = try content.decode(String.self)
          throw Internal.ErrorResponse(headers: headers,
                                       status: status,
                                       message: contentError)
        } catch {
          throw Internal.ErrorResponse(headers: [:],
                                       status: .internalServerError,
                                       message: "failed to decode response with error \(error)")
        }
      }
    }
  }
}
