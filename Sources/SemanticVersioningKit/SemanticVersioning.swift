//
//  SemanticVersioning.swift
//
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation
import Parsing

// MARK: - SemanticVersion
/// A typesafe representation of a Semantic Version
///
/// A semantic version is build with the following schema:
/// ```text
/// MAJOR.MINOR.PATCH
/// ```
/// In addition labels for pre-releases and build meta data can be added.
///
/// Example for pre-release:
/// ```
/// 1.0.0-alpha
/// ```
/// Example for build metadata:
/// ```
/// 1.0.0+20130313144700
/// ```
/// Pre-release identifiers and build metadata are also able to be combined:
/// ```
/// 1.0.0-beta+exp.sha.5114f85
/// ```
public struct SemanticVersion {
    let core: Core

    /// Identifiers denoting a pre-release
    public let preReleaseIdentifiers: [String]

    /// Additional build meta data
    public let buildIdentifiers: [String]

    /// The major version number
    ///
    /// Increased when incompatible API changes are made
    public var major: Int {
        core.major
    }

    /// The minor version number
    ///
    /// Increased when functionality is added in a backwards compatible manner
    public var minor: Int {
        core.minor
    }

    /// The patch version number
    ///
    /// Increased when backwards compatible bug fixes are made
    public var patch: Int {
        core.patch
    }
}

// MARK: - Parser
extension SemanticVersion {
    private nonisolated(unsafe) static let parser: AnyParser<Substring, SemanticVersion> = {
        let alphaNumericAndHypen = Prefix<Substring> { ($0.isLetter || $0.isNumber || $0.isSymbol || $0 == "-") && $0 != "+" }
            .eraseToAnyParser()

        // Pre-Release identifiers
        let preReleaseIdentifier = alphaNumericAndHypen
            .map(String.init)

        let preReleaseIdentifiersParser = Parse {
            "-"
            Many {
                preReleaseIdentifier
            } separator: {
                "."
            }
        }.eraseToAnyParser()

        // Build identifiers
        let buildIdentifier = alphaNumericAndHypen
            .map(String.init)

        let buildIdentifiersParser = Parse {
            "+"
            Many {
                preReleaseIdentifier
            } separator: {
                "."
            }
        }.eraseToAnyParser()

        return Parse {
            Core.parser
            Optionally { preReleaseIdentifiersParser }
            Optionally { buildIdentifiersParser }
        }.map { core, preReleaseIdentifiers, buildIdentifierParser in
            SemanticVersion(
                core: core,
                preReleaseIdentifiers: preReleaseIdentifiers != nil ? preReleaseIdentifiers! : [],
                buildIdentifiers: buildIdentifierParser != nil ? buildIdentifierParser! : []
            )
        }
        .eraseToAnyParser()
    }()

    /// Initialize a new `SemanticVersion` with a `String` representation
    ///
    /// If the `data` does not represent a Semantic Versioning conforming `String` the initialization fails an an error is thrown
    ///
    /// - Parameters:
    ///   - data: String to parse
    public init(input: String) throws {
        self = try Self.parser.parse(input)
    }

    /// Initialize a new Semantic Version
    ///
    /// - Parameters:
    ///   - major: Major version
    ///   - minor: Minor version
    ///   - patch: Patch version
    ///   - preReleaseIdentifiers: Array of pre release identifiers
    ///   - buildIdentifiers: Array of build identifiers
    public init(major: Int, minor: Int, patch: Int, preReleaseIdentifiers: [String] = [], buildIdentifiers: [String] = []) {
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

        // If both vesions are equal, preReleaseIdentifiers are needed to be checked
        if lhs.preReleaseIdentifiers.count == 0 { return false }
        if rhs.preReleaseIdentifiers.count == 0 { return true }

        for (l, r) in zip(lhs.preReleaseIdentifiers, rhs.preReleaseIdentifiers) {
            switch (l.isNumber, r.isNumber) {
            case (true, true):
                let result = l.compare(r, options: .numeric)
                if result == .orderedSame {
                    continue
                }
                return result == .orderedAscending
            case (true, false): return true
            case (false, true): return false
            default:
                if l == r {
                    continue
                }
                return l < r
            }
        }

        return lhs.preReleaseIdentifiers.count < rhs.preReleaseIdentifiers.count
    }
}

// MARK: - Core
extension SemanticVersion {
    struct Core {
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
    public var description: String {
        var rep = "\(major).\(minor).\(patch)"
        if !preReleaseIdentifiers.isEmpty {
            rep.append("-")
            rep.append(preReleaseIdentifiers.joined(separator: "."))
        }
        if !buildIdentifiers.isEmpty {
            rep.append("+")
            rep.append(buildIdentifiers.joined(separator: "."))
        }

        return rep
    }
}

// MARK: - Helpers
extension String {
    fileprivate var isNumber: Bool {
        !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
