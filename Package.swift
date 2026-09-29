// swift-tools-version: 6.2
//
//  lens — HTTP middleware for Swift.
//
//  Port of Rust's tower-http: Compression (gzip), CORS, RateLimit,
//  Timeout, Trace, from_fn. Built on Prism (Service/Layer).
//
import PackageDescription

let package = Package(
    name: "http-lens",
    products: [
        .library(name: "HTTPLens", targets: ["HTTPLens"]),
    ],
    dependencies: [
        .package(path: "../http-model"),
        .package(path: "../http-prism"),
    ],
    targets: [
        .target(
            name: "CLens",
            path: "Sources/CLens",
            publicHeadersPath: "include",
            linkerSettings: [.linkedLibrary("z")]
        ),
        .target(
            name: "HTTPLens",
            dependencies: [
                "CLens",
                .product(name: "HTTPModel", package: "http-model"),
                .product(name: "HTTPPrism", package: "http-prism"),
            ],
            path: "Sources/HTTPLens",
            swiftSettings: baseSwiftSettings
        ),
        .testTarget(
            name: "HTTPLensTests",
            dependencies: ["HTTPLens"],
            path: "Tests/HTTPLensTests",
            swiftSettings: baseSwiftSettings
        ),
    ]
)

var baseSwiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("StrictMemorySafety"),
    ]
}
