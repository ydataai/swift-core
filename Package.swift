// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-core",
  platforms: [
    .macOS(.v12)
  ],
  products: [
    .library(name: "YDataClient", targets: ["YDataClient", "YDataCore", "YDataNIO"]),
    .library(name: "YDataCore", targets: ["YDataCore"]),
    .library(name: "YDataFluent", targets: ["YDataCore", "YDataFluent"]),
    .library(name: "YDataNIO", targets: ["YDataCore"]),
    .library(name: "YDataService", targets: ["YDataCore", "YDataService"]),
    .library(name: "YDataVapor", targets: ["YDataCore", "YDataVapor"]),
    .library(
      name: "YData",
      targets: ["YDataClient", "YDataCore", "YDataFluent", "YDataNIO", "YDataService", "YDataVapor"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.5.2"),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/vapor/vapor.git", from: "4.69.1"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.6.0")
  ],
  targets: [
    .target(
      name: "YDataClient",
      dependencies: [
        .byName(name: "YDataCore"),
        .byName(name: "YDataNIO")
      ],
      path: "Sources/Client"
    ),
    .target(
      name: "YDataCore",
      dependencies: [
        .product(name: "Logging", package: "swift-log")
      ],
      path: "Sources/Core"
    ),
    .target(
      name: "YDataFluent",
      dependencies: [
        .byName(name: "YDataCore"),
        .product(name: "Fluent", package: "fluent")
      ],
      path: "Sources/Fluent"
    ),
    .target(
      name: "YDataNIO",
      dependencies: [
        .byName(name: "YDataCore"),
        .product(name: "NIOCore", package: "swift-nio")
      ],
      path: "Sources/NIO"
    ),
    .target(
      name: "YDataService",
      dependencies: [
        .byName(name: "YDataCore"),
        .byName(name: "YDataNIO")
      ],
      path: "Sources/Service"
    ),
    .target(
      name: "YDataVapor",
      dependencies: [
        .byName(name: "YDataCore"),
        .product(name: "Vapor", package: "vapor")
      ],
      path: "Sources/Vapor"),
    // Test Targets
    .testTarget(
      name: "CoreTests",
      dependencies: ["YDataCore"],
      path: "Tests/Core"
    ),
    .testTarget(
      name: "ClientTests",
      dependencies: [
        "YDataClient",
        .product(name: "NIOCore", package: "swift-nio"),
        .product(name: "NIO", package: "swift-nio")
      ],
      path: "Tests/Client"
    )
  ]
)
