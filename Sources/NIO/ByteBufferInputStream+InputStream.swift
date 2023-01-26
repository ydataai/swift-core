import Foundation
import NIOCore

public final class ByteBufferInputStream: InputStream {
  private var byteBuffer: ByteBuffer
  public override var streamStatus: Stream.Status { .open }

  public init(_ byteBuffer: ByteBuffer) {
    self.byteBuffer = byteBuffer

    super.init(data: Data())
  }

  public override func close() {
    self.byteBuffer.clear()
  }

  public override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
    let length = min(len, byteBuffer.readableBytes)

    guard let bytes = byteBuffer.readBytes(length: length) else {
      return 0
    }

    // Convert into a C pointer and assign it to the provided mutable pointer
    let writtenBytes = bytes.withUnsafeBufferPointer { arrayPointer -> Int in
      arrayPointer.baseAddress.flatMap { pointer -> Int in
        buffer.assign(from: pointer, count: length)
        return length
      } ?? 0
    }

    return writtenBytes
  }

  public override func getBuffer(
    _ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
    length len: UnsafeMutablePointer<Int>
  ) -> Bool {
    return false
  }

  public override var hasBytesAvailable: Bool {
    return self.byteBuffer.readableBytes > 0
  }
}
