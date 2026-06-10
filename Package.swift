// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyApp",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "MyApp", targets: ["MyApp"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "MyAppCore"),
        .executableTarget(
            name: "MyApp",
            dependencies: ["MyAppCore"],
            resources: [
                .process("Resources"),
            ]
        ),
        .testTarget(
            name: "MyAppCoreTests",
            dependencies: ["MyAppCore"]
        ),
    ]
)
