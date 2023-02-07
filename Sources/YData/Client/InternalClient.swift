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

  func send<Request, Response>(_ request: Request) -> EventLoopFuture<Response>
  where Request: InternalRequest, Response: InternalResponse {
    let clientRequest = buildClientRequest(for: request)

    return httpClient.send(clientRequest)
      .always { self.logger.info("response for request \(clientRequest.url): \($0.safeDescription)") }
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
        return .failure(Internal.ErrorResponse(response: response))
      }
    }
  }
}

extension Result: SafeStringConvertible {
  public var safeDescription: String {
    switch self {
    case .failure(let error):
      return "\(error)"
    case .success(let value):
      if let value = value as? SafeStringConvertible {
        return value.safeDescription
      }

      return "\(value)"
    }
  }
}
