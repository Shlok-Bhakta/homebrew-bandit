// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "bandit-mac",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "bandit-mac",
            exclude: ["Info.plist"],
            linkerSettings: [
                // macOS asks for Bluetooth permission with the reason in this plist, and a bare
                // executable has nowhere else to keep it.
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist",
                              "-Xlinker", "Sources/bandit-mac/Info.plist"]),
            ]
        ),
    ]
)
