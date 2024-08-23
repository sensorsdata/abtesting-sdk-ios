// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SensorsABTest",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "SensorsABTest",
            targets: ["SensorsABTest"]),
    ],
    dependencies: [
        .package(name: "SensorsAnalyticsSDK", url: "https://github.com/sensorsdata/sa-sdk-ios-spm.git", from: "4.7.2")
    ],
    targets: [
        .target(
            name: "SensorsABTest",
            dependencies: ["SensorsAnalyticsSDK"],
            path: "SensorsABTest",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")],
            cSettings: [
                .headerSearchPath("."),
                .headerSearchPath("DataManager"),
                .headerSearchPath("Network"),
                .headerSearchPath("SABridge"),
                .headerSearchPath("Store"),
                .headerSearchPath("Utils"),
            ]
        )
    ]
)
