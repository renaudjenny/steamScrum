// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "WebApp",
    products: [
        .executable(name: "WebApp", targets: ["WebApp"])
    ],
    dependencies: [
        .package(name: "Tokamak", url: "https://github.com/swiftwasm/Tokamak", from: "0.3.0")
    ],
    targets: [
        .target(
            name: "WebApp",
            dependencies: [
                .product(name: "TokamakShim", package: "Tokamak")
            ]),
        .testTarget(
            name: "WebAppTests",
            dependencies: ["WebApp"]),
    ]
)