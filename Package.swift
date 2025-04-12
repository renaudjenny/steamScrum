// swift-tools-version:5.9
import PackageDescription

var dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.30.0"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.1.0"),
    .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
    .package(url: "https://github.com/fwcd/swift-qrcode-generator.git", from: "1.0.3")
]

#if os(macOS)
dependencies.append(.package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0"))
#endif

var appTargetDependencies: [PackageDescription.Target.Dependency] = [
    .product(name: "Fluent", package: "fluent"),
    .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
    .product(name: "Vapor", package: "vapor"),
    .product(name: "Leaf", package: "leaf"),
    .product(name: "QRCodeGenerator", package: "swift-qrcode-generator"),
]

#if os(macOS)
appTargetDependencies.append(.product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"))
#endif

let package = Package(
    name: "SteamScrum",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "App",
            dependencies: appTargetDependencies
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),
    ]
)
