import Foundation

public extension String {
  var base64Decoded: String? {
    guard let data = Data(base64Encoded: self) else { return nil }
    return String(data: data, encoding: .utf8)
  }

  var base64Encoded: String? {
    data(using: .utf8)?.base64EncodedString()
  }
}
