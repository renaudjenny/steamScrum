// swift-tools-version:5.2
import PackageDescription

var dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.30.0"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
    .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.1.0"),
    .package(url: "https://github.com/vapor-community/HTMLKit.git", from: "2.0.0"),
    .package(name: "HTMLKitVaporProvider", url: "https://github.com/MatsMoll/htmlkit-vapor-provider.git", from: "1.0.0"),
    .package(url: "https://github.com/renaudjenny/swift-qrcode-generator.git", .branch("master"))
]

#if os(macOS)
dependencies.append(.package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0"))
#endif

var appTargetDependencies: [PackageDescription.Target.Dependency] = [
    .product(name: "Fluent", package: "fluent"),
    .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
    .product(name: "Vapor", package: "vapor"),
    .product(name: "HTMLKit", package: "HTMLKit"),
    .product(name: "HTMLKitVaporProvider", package: "HTMLKitVaporProvider"),
    .product(name: "QRCodeGenerator", package: "swift-qrcode-generator"),
]

#if os(macOS)
appTargetDependencies.append(.product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"))
#endif

let package = Package(
    name: "SteamScrum",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "App",
            dependencies: appTargetDependencies,
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ]),
    ]
)
