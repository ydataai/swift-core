import Foundation
import YDataCore
import YDataNIO

public protocol ClientContext: EventLoopContext, LoggerContext {}

public protocol Client {
  var context: any ClientContext { get }
}
