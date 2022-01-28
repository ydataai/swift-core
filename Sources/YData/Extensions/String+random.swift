import Foundation

public extension String {
  static func random(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?+-*/=_#$%&"
    var s = ""
    for _ in 0 ..< length {
      s.append(letters.randomElement()!)
    }
    return s
  }
}
