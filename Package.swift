// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SwiftUI",
    products: [
        .library(
            name: "SwiftUI",
            targets: ["SwiftUI"]
        ),
        .executable(
            name: "SwiftUIDemo",
            targets: ["SwiftUIDemo"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/AlekSimpson/OpenSwiftUI.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/ciorarn21/SDL.git",
            .branch("master")
        ),
        .package(
            url: "https://github.com/Cosmo/Pixels.git",
            .branch("master")
        ),
    ],
    targets: [
        .target(
            name: "SwiftUI",
            dependencies: [
                "OpenSwiftUI",
                "SDL",
                "Pixels",
            ]
        ),
        .target(
            name: "SwiftUIDemo",
            dependencies: [
                "SwiftUI"
            ]
        ),
        .testTarget(
            name: "SwiftUITests",
            dependencies: ["SwiftUI"]
        ),
    ]
)
