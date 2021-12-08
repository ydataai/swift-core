import NIO

extension ByteBuffer {
  var string: String? { getString(at: 0, length: readableBytes) }
}
