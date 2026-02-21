// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "LeeSourceMonitor",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(
            name: "LeeSourceMonitor",
            path: "Sources/LeeSourceMonitor",
            resources: [
                .copy("Resources"),
            ],
            linkerSettings: [
                .linkedFramework("IOKit"),
                .linkedFramework("CoreFoundation"),
            ]
        ),
    ]
)
