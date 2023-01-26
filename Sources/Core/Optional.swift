import Foundation

precedencegroup OptionalPrecedence {
  associativity: right
}

infix operator ?=: OptionalPrecedence

public extension Optional {
  static func ?=(left: inout Wrapped, right: Optional) {  // swiftlint:disable:this operator_whitespace
    if let right = right {
      left = right
    }
  }

  func tryMap<E: Error>(_ closure: (() -> E)) throws -> Wrapped {
    switch self {
    case .none: throw closure()
    case .some(let value): return value
    }
  }
}
