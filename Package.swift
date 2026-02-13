// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LanguageGame",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LanguageGame",
            targets: ["LanguageGame"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "LanguageGame",
            dependencies: ["Yams"],
            path: "LanguageGame/LanguageGame"
        )
    ]
)
