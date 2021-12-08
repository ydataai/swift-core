import Vapor

public struct HealthCheckHTTPController: HTTPController {
  public func boot(routes: RoutesBuilder) throws {
    routes.get("healthcheck", use: health)
    routes.get("health", use: health)
    routes.get("healthz", use: health)
  }

  private func health(_: Request) -> HTTPStatus {
    .noContent
  }
}
