// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ConvertStringCatalogToAndroidXML",
  platforms: [.macOS(.v13)],
  products: [
    .executable(
      name: "ConvertStringCatalogToAndroidXML", targets: ["ConvertStringCatalogToAndroidXML"])
  ],
  dependencies: [
    .package(url: "https://github.com/liamnichols/xcstrings-tool", exact: "1.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .executableTarget(
      name: "ConvertStringCatalogToAndroidXML",
      dependencies: [
        .product(name: "StringCatalog", package: "xcstrings-tool"),
        .target(name: "StringCatalogConverterLibrary"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]
    ),
    .target(
      name: "StringCatalogConverterLibrary",
      dependencies: [.product(name: "StringCatalog", package: "xcstrings-tool")]
    ),
    // A test target used to develop the macro implementation.
    .testTarget(
      name: "StringCatalogConverterLibraryTests",
      dependencies: [
        .target(name: "StringCatalogConverterLibrary")
      ],
      resources: [.copy("Resources")]
    ),
  ]
)
