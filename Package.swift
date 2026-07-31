// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HalfSnap",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "HalfSnap", path: "Sources"),
    ]
)
