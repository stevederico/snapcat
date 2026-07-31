// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SnapCat",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "SnapCat", path: "Sources"),
    ]
)
