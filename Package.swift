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
        .library(name: "HTTPLens", targets: ["Lens"]),
    ],
    dependencies: [
        .package(url: "https://github.com/akvilary/http.git", from: "0.1.0"),
        .package(url: "https://github.com/akvilary/prism.git", from: "0.1.0"),
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
                .product(name: "HTTP", package: "http"),
                .product(name: "Prism", package: "prism"),
            ],
            path: "Sources/Lens",
            swiftSettings: baseSwiftSettings
        ),
        .testTarget(
            name: "HTTPLensTests",
            dependencies: ["Lens"],
            path: "Tests/LensTests",
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
