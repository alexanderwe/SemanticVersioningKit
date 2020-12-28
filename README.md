# SemanticVersioningKit

<p align="center">
    <a href="https://developer.apple.com/swift/">
      <img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift 5.0">
   </a>
   <a href="https://github.com/apple/swift-package-manager">
      <img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg" alt="SPM">
   </a>

   <a href="https://github.com/alexanderwe/SemanticVersioningKit">
      <img src="https://github.com/alexanderwe/SemanticVersioningKit/workflows/CI/badge.svg" alt="CI">
   </a>
</p>

<p align="center">
    SemanticVersioningKit is a small library to create and parse <a href="https://semver.org">Semantic Versioning</a> conforming representations.
</p>

## Installation

### Swift Package Manager

To integrate using Apple's [Swift Package Manager](https://swift.org/package-manager/), add the following as a dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/alexanderwe/SemanticVersioningKit.git", from: "1.0.0")
]
```

Alternatively navigate to your Xcode project, select `Swift Packages` and click the `+` icon to search for `SemanticVersioningKit`.

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate `SemanticVersioningKit` into your project manually. Simply drag the `Sources` Folder into your Xcode project.

## Usage

At first import `SemanticVersioningKit`

```swift
import SemanticVersioningKit
```

Define a `SemanticVersion` instance

```swift
let version = SemanticVersion(major: 1, minor: 0, patch: 0) // "1.0.0"
let versionWithAdditions = SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha", "1"], buildIdentifiers: ["exp","sha","5114f85"]) // "1.0.0-alpha.1+exp.sha.5114f85"
```

It is also possible to create a `SemanticVersion` from a `String` representation. Just be aware that the initialization can fail due to the used `String` not conforming to the Semantic Versioning format. Therefore an optional `SemanticVersion` is returned in those cases.

```swift
let version = SemanticVersion("1.0.0")
let failed = SemanticVersion(".0.0")
```

## Contributing

Contributions are very welcome 🙌
