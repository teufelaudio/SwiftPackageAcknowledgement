// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import Foundation
import XCTest
import Models

class PackageResolvedFileDecodingTest: XCTestCase {
    func test_GivenASwiftPackagePackageResolvedFile_whenDecoding_itSuccessfullyDecodes() throws {
        guard let path = Bundle.module.url(forResource: "SwiftPackagePackageResolved", withExtension: "json") else {
            XCTFail("Unable to find SamplePackageResolved json!")
            return
        }
        let data = try Data(contentsOf: path)
        XCTAssertNoThrow(try JSONDecoder().decode(ResolvedPackageContent.self, from: data))
    }
    
    func test_GivenAXCWorkspacePackageResolvedFile_whenDecoding_itSuccessfullyDecodes() throws {
        guard let path = Bundle.module.url(forResource: "XCWorkspacePackageResolved", withExtension: "json") else {
            XCTFail("Unable to find SamplePackageResolved json!")
            return
        }
        let data = try Data(contentsOf: path)
        XCTAssertNoThrow(try JSONDecoder().decode(ResolvedPackageContent.self, from: data))
    }
}
