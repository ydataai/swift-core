import Foundation

public protocol EnumModel: Sendable {
  static var schema: String { get }
}

public extension EnumModel {
  static var schema: String { String(describing: Self.self) }
}
