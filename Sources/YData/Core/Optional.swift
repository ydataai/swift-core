import Foundation

precedencegroup OptionalPrecedence {
  associativity: right
}

infix operator ?=: OptionalPrecedence

extension Optional {
  public static func ?=(left: inout Wrapped, right: Optional) {  // swiftlint:disable:this operator_whitespace
    if let right = right {
      left = right
    }
  }
}
