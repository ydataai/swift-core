import Foundation

public extension String {
  static func random(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?+-*/=_#$%&"
    var result = ""
    for _ in 0 ..< length {
      result.append(letters.randomElement()!) // swiftlint:disable:this force_unwrap
    }
    return result
  }
}
