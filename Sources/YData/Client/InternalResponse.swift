import Foundation
import Vapor

public protocol InternalResponse: Sendable {
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

  @inlinable
  func mapToContent<D: Decodable>(_ type: D.Type = D.self) throws -> D {
    try content.decode(type)
  }
}

public extension Internal {
  struct ErrorResponse: Error {
    public var headers: HTTPHeaders
    public var status: HTTPResponseStatus
    public let content: any FabricError

    init(content: any FabricError, headers: HTTPHeaders, status: HTTPResponseStatus) {
      self.content = content
      self.headers = headers
      self.status = status
    }

    init(response: any InternalResponse) {
      self.headers = response.headers
      var status = response.status

      if let fabricError = try? response.content.decode(GenericFabricError.self) {
        self.content = fabricError
      } else if let serviceError = try? response.content.decode(Internal.ServiceError.self) {
        self.content = GenericFabricError(
          description: serviceError.message,
          httpCode: Int(status.code),
          name: "\(Internal.ServiceError.self)",
          returnValue: -1
        )
      } else {
        do {
          let errorMessage = try response.content.decode(String.self)

          self.content = GenericFabricError(
            description: errorMessage,
            httpCode: Int(response.status.code),
            name: "Unknown Error",
            returnValue: -1
          )
        } catch {
          status = .internalServerError
          self.content = GenericFabricError(
            description: "\(error)",
            httpCode: Int(response.status.code),
            name: "Unknown Error",
            returnValue: -1
          )
        }
      }

      self.status = status
    }
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

public protocol SafeStringConvertible {
  var safeDescription: String { get }
}

public extension SafeStringConvertible where Self: InternalResponse {
  var safeDescription: String {
    var desc = ["HTTP/1.1 \(status.code) \(status.reasonPhrase)"]
    desc += self.headers.map { "\($0.name): \($0.value)" }
    return desc.joined(separator: "\n")
  }
}
