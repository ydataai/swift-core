import Foundation

public struct GenericFabricError: FabricError {
  public var context: [String: String]?
  public var description: String
  public var httpCode: Int = 500
  public var name: String
  public var returnValue: Int

  public init(
    context: [String: String]? = nil,
    description: String,
    httpCode: Int? = 500,
    name: String = "\(Self.self)",
    returnValue: Int
  ) {
    self.context = context
    self.description = description
    if let httpCode = httpCode {
      self.httpCode = httpCode
    }
    self.name = name
    self.returnValue = returnValue
  }
}
