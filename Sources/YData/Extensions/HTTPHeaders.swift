import Vapor

extension HTTPHeaders {
  init(_ headers: [String: String]) {
    self.init(headers.map { ($0, $1) })
  }
}
