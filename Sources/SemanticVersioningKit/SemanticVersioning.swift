//
//  SemanticVersioning.swift
//
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation
import Parsing

// MARK: - SemanticVersionParseError

/// An error thrown when a string cannot be parsed as a semantic version.
public enum SemanticVersionParseError: Error {
    /// The provided string does not conform to the Semantic Versioning specification.
    ///
    /// - Parameter input: The string that failed to parse.
    case invalidInput(String)
}

// MARK: - SemanticVersion

/// A type-safe representation of a [Semantic Version](https://semver.org).
///
/// A semantic version consists of three required numeric components and two optional
/// extension components, following this structure:
///
/// ```
/// MAJOR.MINOR.PATCH[-prerelease][+build]
/// ```
///
/// ## Creating a Version
///
/// Create a version directly from its numeric components:
///
/// ```swift
/// let release = SemanticVersion(major: 2, minor: 0, patch: 0)
/// // "2.0.0"
/// ```
///
/// Optionally include pre-release identifiers or build metadata:
///
/// ```swift
/// let preRelease = SemanticVersion(
///     major: 1, minor: 0, patch: 0,
///     preReleaseIdentifiers: ["alpha", "1"]
/// )
/// // "1.0.0-alpha.1"
///
/// let withBuild = SemanticVersion(
///     major: 1, minor: 0, patch: 0,
///     buildIdentifiers: ["exp", "sha", "5114f85"]
/// )
/// // "1.0.0+exp.sha.5114f85"
///
/// let full = SemanticVersion(
///     major: 1, minor: 0, patch: 0,
///     preReleaseIdentifiers: ["beta"],
///     buildIdentifiers: ["exp", "sha", "5114f85"]
/// )
/// // "1.0.0-beta+exp.sha.5114f85"
/// ```
///
/// Or parse a version from a string:
///
/// ```swift
/// let version = try SemanticVersion(input: "1.0.0-alpha.1+exp.sha.5114f85")
/// ```
///
/// ## Comparing Versions
///
/// ``SemanticVersion`` conforms to `Comparable`, following the precedence rules
/// defined in the Semantic Versioning specification:
///
/// ```swift
/// let v1 = SemanticVersion(major: 1, minor: 0, patch: 0)
/// let v2 = SemanticVersion(major: 2, minor: 0, patch: 0)
/// v1 < v2 // true
/// ```
///
/// A pre-release version always has lower precedence than its associated release:
///
/// ```swift
/// let alpha = SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha"])
/// let release = SemanticVersion(major: 1, minor: 0, patch: 0)
/// alpha < release // true
/// ```
///
/// - Note: Build metadata is ignored entirely when determining version precedence.
public nonisolated struct SemanticVersion: Sendable {
    let core: Core

    /// The dot-separated identifiers denoting a pre-release version.
    ///
    /// For the version string `1.0.0-alpha.1`, this property returns `["alpha", "1"]`.
    /// Returns an empty array when no pre-release identifiers are present.
    public let preReleaseIdentifiers: [String]

    /// The dot-separated identifiers providing additional build metadata.
    ///
    /// For the version string `1.0.0+exp.sha.5114f85`, this property returns
    /// `["exp", "sha", "5114f85"]`. Returns an empty array when no build
    /// identifiers are present.
    ///
    /// - Note: Build metadata is ignored when determining version precedence.
    public let buildIdentifiers: [String]

    /// The major version number.
    ///
    /// Represents the first numeric component of the version string. For example,
    /// the major version of `2.1.3` is `2`.
    ///
    /// Increment this when making incompatible API changes.
    public var major: Int {
        core.major
    }

    /// The minor version number.
    ///
    /// Represents the second numeric component of the version string. For example,
    /// the minor version of `2.1.3` is `1`.
    ///
    /// Increment this when adding functionality in a backwards-compatible manner.
    public var minor: Int {
        core.minor
    }

    /// The patch version number.
    ///
    /// Represents the third numeric component of the version string. For example,
    /// the patch version of `2.1.3` is `3`.
    ///
    /// Increment this when making backwards-compatible bug fixes.
    public var patch: Int {
        core.patch
    }
}

// MARK: - Parsing

extension SemanticVersion {
    private nonisolated(unsafe) static let parser: AnyParser<Substring, SemanticVersion> = {
        let alphaNumericAndHyphen = Prefix<Substring> {
            ($0.isLetter || $0.isNumber || $0.isSymbol || $0 == "-") && $0 != "+"
        }
        .eraseToAnyParser()

        let preReleaseIdentifiersParser = Parse {
            "-"
            Many { alphaNumericAndHyphen.map(String.init) } separator: { "." }
        }
        .eraseToAnyParser()

        let buildIdentifiersParser = Parse {
            "+"
            Many { alphaNumericAndHyphen.map(String.init) } separator: { "." }
        }
        .eraseToAnyParser()

        return Parse {
            Core.parser
            Optionally { preReleaseIdentifiersParser }
            Optionally { buildIdentifiersParser }
        }
        .map { core, preReleaseIdentifiers, buildIdentifiers in
            SemanticVersion(
                core: core,
                preReleaseIdentifiers: preReleaseIdentifiers ?? [],
                buildIdentifiers: buildIdentifiers ?? []
            )
        }
        .eraseToAnyParser()
    }()

    /// Creates a semantic version by parsing a string.
    ///
    /// The string must follow the [Semantic Versioning](https://semver.org) format:
    ///
    /// ```swift
    /// // Core version only
    /// let v1 = try SemanticVersion(input: "1.0.0")
    ///
    /// // With pre-release identifiers
    /// let v2 = try SemanticVersion(input: "1.0.0-alpha.1")
    ///
    /// // With build metadata
    /// let v3 = try SemanticVersion(input: "1.0.0+20130313144700")
    ///
    /// // With both pre-release identifiers and build metadata
    /// let v4 = try SemanticVersion(input: "1.0.0-beta+exp.sha.5114f85")
    /// ```
    ///
    /// - Parameter input: A string conforming to the Semantic Versioning specification.
    /// - Throws: ``SemanticVersionParseError/invalidInput(_:)`` if `input` is not a valid
    ///   semantic version string.
    public init(input: String) throws(SemanticVersionParseError) {
        do {
            self = try Self.parser.parse(input)
        } catch {
            throw SemanticVersionParseError.invalidInput(input)
        }
    }

    /// Creates a semantic version from its individual components.
    ///
    /// ```swift
    /// // "1.0.0"
    /// let release = SemanticVersion(major: 1, minor: 0, patch: 0)
    ///
    /// // "1.0.0-alpha.1"
    /// let preRelease = SemanticVersion(
    ///     major: 1, minor: 0, patch: 0,
    ///     preReleaseIdentifiers: ["alpha", "1"]
    /// )
    ///
    /// // "1.0.0+exp.sha.5114f85"
    /// let withBuild = SemanticVersion(
    ///     major: 1, minor: 0, patch: 0,
    ///     buildIdentifiers: ["exp", "sha", "5114f85"]
    /// )
    ///
    /// // "1.0.0-alpha.1+exp.sha.5114f85"
    /// let full = SemanticVersion(
    ///     major: 1, minor: 0, patch: 0,
    ///     preReleaseIdentifiers: ["alpha", "1"],
    ///     buildIdentifiers: ["exp", "sha", "5114f85"]
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - major: The major version. Increment for incompatible API changes.
    ///   - minor: The minor version. Increment for backwards-compatible new functionality.
    ///   - patch: The patch version. Increment for backwards-compatible bug fixes.
    ///   - preReleaseIdentifiers: Identifiers denoting a pre-release version. Defaults to `[]`.
    ///   - buildIdentifiers: Identifiers providing additional build metadata. Defaults to `[]`.
    public init(
        major: Int,
        minor: Int,
        patch: Int,
        preReleaseIdentifiers: [String] = [],
        buildIdentifiers: [String] = []
    ) {
        self.core = Core(major: major, minor: minor, patch: patch)
        self.preReleaseIdentifiers = preReleaseIdentifiers
        self.buildIdentifiers = buildIdentifiers
    }
}

// MARK: - Comparable

extension SemanticVersion: Comparable {
    public static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        !(lhs < rhs) && !(lhs > rhs)
    }

    // Credit: https://github.com/glwithu06/Semver.swift/blob/master/Sources/Semver.swift
    public static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        for (left, right) in zip([lhs.major, lhs.minor, lhs.patch], [rhs.major, rhs.minor, rhs.patch]) where left != right {
            return left < right
        }

        if lhs.preReleaseIdentifiers.isEmpty { return false }
        if rhs.preReleaseIdentifiers.isEmpty { return true }

        for (left, right) in zip(lhs.preReleaseIdentifiers, rhs.preReleaseIdentifiers) {
            switch (left.isNumber, right.isNumber) {
            case (true, true):
                let result = left.compare(right, options: .numeric)
                if result == .orderedSame { continue }
                return result == .orderedAscending
            case (true, false): return true
            case (false, true): return false
            default:
                if left == right { continue }
                return left < right
            }
        }

        return lhs.preReleaseIdentifiers.count < rhs.preReleaseIdentifiers.count
    }
}

// MARK: - Core

extension SemanticVersion {
    struct Core: Sendable {
        let major: Int
        let minor: Int
        let patch: Int

        nonisolated(unsafe) static let parser: AnyParser<Substring, SemanticVersion.Core> = Parse(Core.init) {
            Int.parser()
            "."
            Int.parser()
            "."
            Int.parser()
        }.eraseToAnyParser()
    }
}

// MARK: - CustomStringConvertible

extension SemanticVersion: CustomStringConvertible {
    /// A string representation of the semantic version.
    ///
    /// Returns the version formatted as `MAJOR.MINOR.PATCH`, appending pre-release
    /// identifiers and build metadata where present:
    ///
    /// ```swift
    /// SemanticVersion(major: 1, minor: 0, patch: 0).description
    /// // "1.0.0"
    ///
    /// SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha", "1"]).description
    /// // "1.0.0-alpha.1"
    ///
    /// SemanticVersion(
    ///     major: 1, minor: 0, patch: 0,
    ///     preReleaseIdentifiers: ["alpha", "1"],
    ///     buildIdentifiers: ["exp", "sha", "5114f85"]
    /// ).description
    /// // "1.0.0-alpha.1+exp.sha.5114f85"
    /// ```
    public var description: String {
        var result = "\(major).\(minor).\(patch)"
        if !preReleaseIdentifiers.isEmpty {
            result.append("-")
            result.append(preReleaseIdentifiers.joined(separator: "."))
        }
        if !buildIdentifiers.isEmpty {
            result.append("+")
            result.append(buildIdentifiers.joined(separator: "."))
        }
        return result
    }
}

// MARK: - Helpers

extension String {
    fileprivate var isNumber: Bool {
        !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
