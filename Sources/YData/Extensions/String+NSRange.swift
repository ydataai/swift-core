import Foundation

public extension String {
  var nsRange: NSRange { NSRange(startIndex..<endIndex, in: self) }
}
