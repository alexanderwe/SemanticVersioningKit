//
//  SemanticVersionests.swift
//
//
//  Created by Alexander Weiß on 28.12.20.
//

import Foundation
import Testing
@testable import SemanticVersioningKit

@Suite
struct SemanticVersionTests {
    @Test
    func coreVersionParsed() throws {
        // Given
        let semverString = "1.0.0"

        // When
        let version = try #require(try? SemanticVersion(input: semverString))

        // Then
        #expect(version.major == 1)
        #expect(version.minor == 0)
        #expect(version.patch == 0)
    }

    @Test
    func preReleaseIdentifiers1Parsed() throws {
        // Given
        let semverString = "1.0.0-alpha"

        // When
        let version = try #require(try? SemanticVersion(input: semverString))

        // Then
        #expect(version.major == 1)
        #expect(version.minor == 0)
        #expect(version.patch == 0)

        #expect(version.buildIdentifiers.count == 0)

        #expect(version.preReleaseIdentifiers.count == 1)
        #expect(version.preReleaseIdentifiers[0] == "alpha")
    }

    @Test
    func preReleaseIdentifiers2Parsed() throws {
        // Given
        let semverString = "1.0.0-alpha.1"

        // When
        let version = try #require(try? SemanticVersion(input: semverString))

        #expect(version.major == 1)
        #expect(version.minor == 0)
        #expect(version.patch == 0)

        #expect(version.buildIdentifiers.count == 0)

        #expect(version.preReleaseIdentifiers.count == 2)
        #expect(version.preReleaseIdentifiers[0] == "alpha")
        #expect(version.preReleaseIdentifiers[1] == "1")
    }

    @Test
    func preReleaseIdentifiers3Parsed() throws {
        // Given
        let semverString = "1.0.0-x.7.z.92"

        // When
        let version = try #require(try? SemanticVersion(input: semverString))

        // Then
        #expect(version.major == 1)
        #expect(version.minor == 0)
        #expect(version.patch == 0)

        #expect(version.buildIdentifiers.count == 0)

        #expect(version.preReleaseIdentifiers.count == 4)
        #expect(version.preReleaseIdentifiers[0] == "x")
        #expect(version.preReleaseIdentifiers[1] == "7")
        #expect(version.preReleaseIdentifiers[2] == "z")
        #expect(version.preReleaseIdentifiers[3] == "92")
    }

    @Test
    func preReleaseIdentifiers4Parsed() throws {
        // Given
        let semverString = "1.0.0-x-y-z.-"

        // When
        let version = try #require(try? SemanticVersion(input: semverString))

        // Then
        #expect(version.major == 1)
        #expect(version.minor == 0)
        #expect(version.patch == 0)

        #expect(version.buildIdentifiers.count == 0)

        #expect(version.preReleaseIdentifiers.count == 2)
        #expect(version.preReleaseIdentifiers[0] == "x-y-z")
        #expect(version.preReleaseIdentifiers[1] == "-")
    }

    @Test
    func buildIdentifiers1Parsed() throws {
        // Given
        let semverString = "1.0.0+20130313144700"

        // When
        let version = try #require(try? SemanticVersion(input: semverString))

        // Then
        #expect(version.major == 1)
        #expect(version.minor == 0)
        #expect(version.patch == 0)

        #expect(version.preReleaseIdentifiers.count == 0)

        #expect(version.buildIdentifiers.count == 1)
        #expect(version.buildIdentifiers[0] == "20130313144700")
    }

    @Test
    func buildIdentifiers2Parsed() throws {
        // Given
        let semverString = "1.0.0+exp.sha.5114f85"

        // When
        let version = try #require(try? SemanticVersion(input: semverString))

        // Then
        #expect(version.major == 1)
        #expect(version.minor == 0)
        #expect(version.patch == 0)

        #expect(version.preReleaseIdentifiers.count == 0)

        #expect(version.buildIdentifiers.count == 3)
        #expect(version.buildIdentifiers[0] == "exp")
        #expect(version.buildIdentifiers[1] == "sha")
        #expect(version.buildIdentifiers[2] == "5114f85")
    }

    @Test
    func buildIdentifiers3Parsed() throws {
        // Given
        let semverString = "1.0.0+21AF26D3--117B344092BD"

        // When
        let version = try #require(try? SemanticVersion(input: semverString))

        // Then
        #expect(version.major == 1)
        #expect(version.minor == 0)
        #expect(version.patch == 0)

        #expect(version.preReleaseIdentifiers.count == 0)

        #expect(version.buildIdentifiers.count == 1)
        #expect(version.buildIdentifiers[0] == "21AF26D3--117B344092BD")
    }

    @Test
    func preAndBuildIdentifiersParsed() throws {
        // Given
        let semverString = "1.0.0-alpha+001"

        // When
        let version = try #require(try? SemanticVersion(input: semverString))

        // Then
        #expect(version.major == 1)
        #expect(version.minor == 0)
        #expect(version.patch == 0)

        #expect(version.preReleaseIdentifiers.count == 1)
        #expect(version.preReleaseIdentifiers[0] == "alpha")

        #expect(version.buildIdentifiers.count == 1)
        #expect(version.buildIdentifiers[0] == "001")
    }

    @Test
    func stringRepresentationIsCorrect() {
        // Given
        let coreOnly = SemanticVersion(major: 1, minor: 0, patch: 0)
        let withPreRelease = SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha", "1"])
        let withBuildIdentifiers = SemanticVersion(major: 1, minor: 0, patch: 0, buildIdentifiers: ["21AF26D3--117B344092BD"])
        let withPreReleaseAndBuildIdentifiers = SemanticVersion(
            major: 1,
            minor: 0,
            patch: 0,
            preReleaseIdentifiers: ["alpha", "1"],
            buildIdentifiers: ["exp", "sha", "5114f85"]
        )

        // Then
        #expect("1.0.0" == "\(coreOnly)")
        #expect("1.0.0-alpha.1" == "\(withPreRelease)")
        #expect("1.0.0+21AF26D3--117B344092BD" == "\(withBuildIdentifiers)")
        #expect("1.0.0-alpha.1+exp.sha.5114f85" == "\(withPreReleaseAndBuildIdentifiers)")
    }

    @Test(arguments: [
        (SemanticVersion(major: 1, minor: 0, patch: 0), SemanticVersion(major: 2, minor: 0, patch: 0)),
        (SemanticVersion(major: 1, minor: 1, patch: 0), SemanticVersion(major: 1, minor: 2, patch: 0)),
        (SemanticVersion(major: 1, minor: 0, patch: 1), SemanticVersion(major: 1, minor: 0, patch: 2)),
        (
            SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha"]),
            SemanticVersion(major: 1, minor: 0, patch: 0)
        ),
        (
            SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha"]),
            SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha", "1"])
        ),
        (
            SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha", "1"]),
            SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha", "2"])
        )
    ])
    func comparisonsAreCorrect(versions: (SemanticVersion, SemanticVersion)) throws {
        let (left, right) = versions

        #expect(left < right)
        #expect(right > left)
        #expect(left != right)
    }
}
