import Foundation

public struct GenericFabricError: FabricError {
  public var context: [String: String]?
  public var description: String
  public var httpCode: Int = 500
  internal var _name: String? // swiftlint:disable:this identifier_name
  public var returnValue: Int

  public var name: String {
    get {
      _name ?? "\(Self.self)"
    }

    set {
      _name = newValue
    }
  }

  public init(
    context: [String: String]? = nil,
    description: String,
    httpCode: Int? = 500,
    name: String? = nil,
    returnValue: Int
  ) {
    self.context = context
    self.description = description
    if let httpCode {
      self.httpCode = httpCode
    }
    self._name = name
    self.returnValue = returnValue
  }
}
