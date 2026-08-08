// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftZSTD",
    products: [
        .library(
            name: "SwiftZSTD",
            targets: ["SwiftZSTD"]),
    ],
    dependencies: [ .package(url: "https://github.com/facebook/zstd", from: "1.5.7") ],
    targets: [
        .target(
            name: "SwiftZSTD",
            dependencies: [.target(name: "SwiftZSTDC", condition: .when(platforms: [.macOS, .iOS])), .product(name: "libzstd", package: "zstd")]),
        .target(
            name: "SwiftZSTDC",
            dependencies: [.product(name: "libzstd", package: "zstd")]),
        .testTarget(
            name: "SwiftZSTDTests",
            dependencies: ["SwiftZSTD"]),
    ]
)
