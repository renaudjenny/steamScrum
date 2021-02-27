// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "TokamakApp",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "TokamakApp", targets: ["TokamakApp"])
    ],
    dependencies: [
        .package(name: "Tokamak", url: "https://github.com/TokamakUI/Tokamak", from: "0.6.1")
    ],
    targets: [
        .target(
            name: "TokamakApp",
            dependencies: [
                .product(name: "TokamakShim", package: "Tokamak")
            ]),
        .testTarget(
            name: "TokamakAppTests",
            dependencies: ["TokamakApp"]),
    ]
)