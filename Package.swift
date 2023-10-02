// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if (os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
let package = Package(
    name: "Transmission",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Transmission",
            targets: ["Transmission"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionTypes.git", branch: "release"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
        .package(url: "https://github.com/OperatorFoundation/Chord", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/Datable", from: "4.0.0"),
        .package(url: "https://github.com/OperatorFoundation/Transport", branch: "release"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionMacOS", branch: "release"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Transmission",
            dependencies: ["TransmissionTypes", "TransmissionMacOS", "Chord", "Datable", "Transport", .product(name: "Logging", package: "swift-log")]
        ),
        .testTarget(
            name: "TransmissionTests",
            dependencies: ["Transmission", "Datable"]),
    ],
    swiftLanguageVersions: [.v5]
)
#else
let package = Package(
    name: "Transmission",
    platforms: [.macOS(.v10_15)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Transmission",
            targets: ["Transmission"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionTypes.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
        .package(url: "https://github.com/OperatorFoundation/Chord", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Datable", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/Transport", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/TransmissionLinux", branch: "main"),
        .package(url: "https://github.com/OperatorFoundation/SwiftQueue", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Transmission",
            dependencies: ["TransmissionTypes", "Chord", "Datable", "Transport", "TransmissionLinux", "SwiftQueue", .product(name: "Logging", package: "swift-log")]
        ),
        .testTarget(
            name: "TransmissionTests",
            dependencies: ["Transmission", "Datable"]),
    ],
    swiftLanguageVersions: [.v5]
)
#endif
