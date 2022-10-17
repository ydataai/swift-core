import Foundation

public protocol FabricError: Error {
  var context: [AnyHashable: Any]? { get }
  var description: String { get }
  var httpCode: Int? { get }
  var name: String { get }
  var returnValue: Int { get }
}

extension FabricError {
  var name: String { "\(Self.self)" }
}


class GenericFabricError: FabricError {
  var context: [AnyHashable: Any]?
  var description: String
  var httpCode: Int?
  var _name: String? // swiftlint:disable:this identifier_name
  var returnValue: Int

  var name: String {
    get {
      _name ?? "\(Self.self)"
    }

    set {
      _name = newValue
    }
  }

  init(
    context: [AnyHashable: Any]? = nil,
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

