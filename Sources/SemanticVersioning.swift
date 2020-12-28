//
//  SemanticVersioning.swift
//
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation
import Parsing

// MARK: - SemanticVersion
public struct SemanticVersion {

    let core: Core
    public let preReleaseIdentifiers: [String]
    public let buildIdentifiers: [String]
    
    public var major: Int {
        return core.major
    }
    
    public var minor: Int {
        core.minor
    }
    
    public var patch: Int {
        core.patch
    }
}

// MARK: - Parser
/// A typesafe representation of a Semantic Version
extension SemanticVersion {
    
    private static let parser: AnyParser<Substring, SemanticVersion> = {
        
        let alphaNumericAndHypen = Prefix<Substring>(while: { $0.isLetter || $0.isNumber || $0 == "-" })
            
        // Pre-Release identifiers
        let preReleaseIdentifier = alphaNumericAndHypen
            .map(String.init)
        
        let preReleaseIdentifiersParser = Skip(StartsWith("-"))
            .take(Many(preReleaseIdentifier, separator: StartsWith(".")))
            
        // Build identifiers
        let buildIdentifier = alphaNumericAndHypen
            .map(String.init)
        
        let buildIdentifierParser = Skip(StartsWith("+"))
            .take(Many(buildIdentifier, separator: StartsWith(".")))
        
        return Core.parser
            .take(Parsers.OptionalParser(preReleaseIdentifiersParser))
            .take(Parsers.OptionalParser(buildIdentifierParser))
            .map { core, preReleaseIdentifiers, buildIdentifierParser  in
                return SemanticVersion(core: core,
                                       preReleaseIdentifiers: preReleaseIdentifiers != nil ? preReleaseIdentifiers! : [],
                                       buildIdentifiers:  buildIdentifierParser != nil ? buildIdentifierParser! : []
                )
            }
            .eraseToAnyParser()
    }()
    
    
    /// Initialize a new `SemanticVersion` with a `String` representation
    ///
    /// If the `data` does not represent a Semantic Versioning conforming `String` the initialization fails and `nil` is returned.
    ///
    /// - Parameters:
    ///   - data: String to parse
    public init?(data: String) {
        guard let match = SemanticVersion.parser.parse(data[...]) else {
            return nil
        }
        
        self = match
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

//MARK: - Comparable
extension SemanticVersion: Comparable {
    public static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return !(lhs < rhs) && !(lhs > rhs)
    }
    
    //Credit: https://github.com/glwithu06/Semver.swift/blob/master/Sources/Semver.swift
    public static func <(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        
        for (left, right) in zip([lhs.major, lhs.minor, lhs.patch],  [rhs.major, rhs.minor, rhs.patch]) where left != right {
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
    internal struct Core {
        let major: Int
        let minor: Int
        let patch: Int
        
        internal static let parser:  AnyParser<Substring, SemanticVersion.Core> = {
            
           return Int.parser()
                .skip(StartsWith("."))
                .take(Int.parser())
                .skip(StartsWith("."))
                .take(Int.parser())
                .map { major, minor, patch in
                    return Core(major:major, minor: minor, patch: patch)
                }
                .eraseToAnyParser()

        }()
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
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
