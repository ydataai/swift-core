import NIO

extension ByteBuffer {
  public var string: String? { getString(at: 0, length: readableBytes) }
}
