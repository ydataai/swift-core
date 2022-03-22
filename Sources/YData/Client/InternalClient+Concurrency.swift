import Foundation
import Vapor

extension InternalClient {
  public func send<Request: InternalRequest, Resp: Response>(_ request: Request) async throws -> Resp
  where Request.Content: Encodable {
    return try await self.send(request).get()
  }
  
  public func send<Request: InternalRequest, Resp: Response>(_ request: Request) async throws -> Resp {
    return try await self.send(request).get()
  }
  
  public func send<Request: InternalRequest, Resp: InternalModel>(_ request: Request) async throws -> Resp
  where Request.Content: Encodable {
    
    var clientRequest = buildClientRequest(for: request)
    
    try request.content.flatMap { try clientRequest.content.encode($0, as: .json) }
    
    return try await httpClient.send(clientRequest).mapToInternalModel()
  }
  
  public func send<Request: InternalRequest, Resp: InternalModel>(_ request: Request) async throws -> Resp {
    
    let clientRequest = buildClientRequest(for: request)
    
    return try await httpClient.send(clientRequest).mapToInternalModel()
  }
}

private extension ClientResponse  {
  func mapToInternalModel<R>() async throws -> R where R: InternalModel {
    switch status.code {
    case (100..<400):
      do {
        return try content.decode(R.self)
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

