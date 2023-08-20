// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SemanticVersioningKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SemanticVersioningKit",
            targets: ["SemanticVersioningKit"]),
    ],
    dependencies: [
        // Source code dependencies
        .package(url: "https://github.com/pointfreeco/swift-parsing", exact: "0.13.0"),

        // Plugins
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.52.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SemanticVersioningKit",
            dependencies: [.product(name: "Parsing", package: "swift-parsing")],
            path: "Sources"
        ),
        .testTarget(
            name: "SemanticVersioningKitTests",
            dependencies: ["SemanticVersioningKit"],
            path: "Tests"
        ),
    ]
)
