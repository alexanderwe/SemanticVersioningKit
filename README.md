# SemanticVersioningKit


<p align="center">

   <a href="https://swiftpackageindex.com/alexanderwe/SemanticVersioningKit">
      <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Falexanderwe%2FSemanticVersioningKit%2Fbadge%3Ftype%3Dswift-versions" />
   </a>

   <a href="https://swiftpackageindex.com/alexanderwe/SemanticVersioningKit">
    <img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Falexanderwe%2FSemanticVersioningKit%2Fbadge%3Ftype%3Dplatforms" />
   </a>

   <a href="https://github.com/alexanderwe/SemanticVersioningKit">
      <img src="https://github.com/alexanderwe/SemanticVersioningKit/workflows/Main%20Branch%20CI/badge.svg" alt="CI">
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
    .package(url: "https://github.com/alexanderwe/SemanticVersioningKit.git", from: "2.1.2")
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

It is also possible to create a `SemanticVersion` from a `String` representation. Just be aware that the initialization can fail due to the used `String` not conforming to the Semantic Versioning format.

```swift
let version = try SemanticVersion(input: "1.0.0")
let failed = try SemanticVersion(input: ".0.0")
```

## Contributing

Contributions are very welcome 🙌
