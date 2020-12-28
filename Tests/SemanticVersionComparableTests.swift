//
//  SemanticVersionComparableTests.swift
//  
//
//  Created by Alexander Weiß on 28.12.20.
//

import Foundation
import XCTest
@testable import SemanticVersioningKit

final class SemanticVersionComparableTests: XCTestCase {
    
    func testCoreMajorComparison() throws {
        let left = SemanticVersion(major: 1, minor: 0, patch: 0)
        let right = SemanticVersion(major: 2, minor: 0, patch: 0)
        
        XCTAssertLessThan(left, right)
        XCTAssertGreaterThan(right, left)
        XCTAssertNotEqual(left, right)
    }
    
    func testCoreMinorComparison() throws {
        let left = SemanticVersion(major: 1, minor: 1, patch: 0)
        let right = SemanticVersion(major: 1, minor: 2, patch: 0)
        
        XCTAssertLessThan(left, right)
        XCTAssertGreaterThan(right, left)
        XCTAssertNotEqual(left, right)
    }
    
    func testCorePatchComparison() throws {
        let left = SemanticVersion(major: 1, minor: 0, patch: 1)
        let right = SemanticVersion(major: 1, minor: 0, patch: 2)
        
        XCTAssertLessThan(left, right)
        XCTAssertGreaterThan(right, left)
        XCTAssertNotEqual(left, right)
    }
    
    func testCoreReleaseIdentifiers1() throws {
        let left = SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha"])
        let right = SemanticVersion(major: 1, minor: 0, patch: 0)
        
        XCTAssertLessThan(left, right)
        XCTAssertGreaterThan(right, left)
        XCTAssertNotEqual(left, right)
    }
    
    func testCoreReleaseIdentifiers2() throws {
        let left = SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha"])
        let right = SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha", "1"])
        
        XCTAssertLessThan(left, right)
        XCTAssertGreaterThan(right, left)
        XCTAssertNotEqual(left, right)
    }
    
    func testCoreReleaseIdentifiers3() throws {
        let left = SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha", "1"])
        let right = SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha", "2"])
        
        let versionWithAdditions = SemanticVersion(major: 1, minor: 0, patch: 0, preReleaseIdentifiers: ["alpha", "1"], buildIdentifiers: ["20130313144700"])
        print(versionWithAdditions)
        
        XCTAssertLessThan(left, right)
        XCTAssertGreaterThan(right, left)
        XCTAssertNotEqual(left, right)
    }

    static var allTests = [
        ("testCoreMajorComparison", testCoreMajorComparison),
        ("testCoreMinorComparison", testCoreMinorComparison),
        ("testCorePatchComparison", testCorePatchComparison),
        ("testCoreReleaseIdentifiers1", testCoreReleaseIdentifiers1),
        ("testCoreReleaseIdentifiers2", testCoreReleaseIdentifiers2),
        ("testCoreReleaseIdentifiers3", testCoreReleaseIdentifiers3)
    ]
}
