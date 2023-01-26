import Fluent

public extension Model {
  static var schema: String { String(describing: Self.self) }
}
