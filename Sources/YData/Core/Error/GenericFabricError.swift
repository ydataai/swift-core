import Foundation

public class GenericFabricError: FabricError {
  public var context: [String: String]?
  public var description: String
  public var httpCode: Int?
  var _name: String? // swiftlint:disable:this identifier_name
  public var returnValue: Int

  public var name: String {
    get {
      _name ?? "\(Self.self)"
    }

    set {
      _name = newValue
    }
  }

  init(
    context: [String: String]? = nil,
    description: String,
    httpCode: Int? = nil,
    name: String? = nil,
    returnValue: Int
  ) {
    self.context = context
    self.description = description
    self.httpCode = httpCode
    self._name = name
    self.returnValue = returnValue
  }
}
