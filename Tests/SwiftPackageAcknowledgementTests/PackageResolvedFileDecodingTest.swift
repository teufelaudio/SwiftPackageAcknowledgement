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
        let decodedResolvedPackage = try JSONDecoder().decode(ResolvedPackageContent.self, from: data)
        XCTAssertEqual(decodedResolvedPackage, swiftPackageResolvedObject)
    }
    
    func test_GivenAXCWorkspacePackageResolvedFile_whenDecoding_itSuccessfullyDecodes() throws {
        guard let path = Bundle.module.url(forResource: "XCWorkspacePackageResolved", withExtension: "json") else {
            XCTFail("Unable to find SamplePackageResolved json!")
            return
        }
        let data = try Data(contentsOf: path)
        let decodedResolvedPackage = try JSONDecoder().decode(ResolvedPackageContent.self, from: data)
        XCTAssertEqual(decodedResolvedPackage, xcWorkSpacePackageResolvedObject)
    }
}

// MARK: - XCWorkspace Resolved Package Content Comparison Object

extension PackageResolvedFileDecodingTest {
    private var xcWorkSpacePackageResolvedObject: ResolvedPackageContent {
        ResolvedPackageContent(
            object: ResolvedPackageObject(
                pins: [
                    .init(
                        package: "AcknowList",
                        repositoryURL: URL(string: "https://github.com/teufelaudio/AcknowList.git")!,
                        state: .init(
                            branch: "xcode-13",
                            revision: "cfaa05135ca7b625e2fc3c454e0ecff3529c2d25"
                        )
                    ),
                    .init(
                        package: "BridgeMiddleware",
                        repositoryURL: URL(string: "https://github.com/SwiftRex/BridgeMiddleware")!,
                        state: .init(
                            revision: "6c886f95a877f7fb75bd7f4043a28d6880c5fff2",
                            version: "0.1.3"
                        )
                    ),
                    .init(
                        package: "combine-schedulers",
                        repositoryURL: URL(string: "https://github.com/pointfreeco/combine-schedulers")!,
                        state: .init(
                            revision: "9dc9cbe4bc45c65164fa653a563d8d8db61b09bb",
                            version: "1.0.0"
                        )
                    ),
                    .init(
                        package: "CombineBonjour",
                        repositoryURL: URL(string: "https://github.com/teufelaudio/CombineBonjour.git")!,
                        state: .init(
                            revision: "d44454a4fa1944948b205f2dffec61b066361923",
                            version: "0.1.10"
                        )
                    ),
                    .init(
                        package: "CombineExternalAccessory",
                        repositoryURL: URL(string: "https://github.com/teufelaudio/CombineExternalAccessory.git")!,
                        state: .init(
                            revision: "bab65b0be21e91bed9d3af7ee3569344fc265932",
                            version: "0.1.0"
                        )
                    )
                ]
            ),
            version: 1
        )
    }
}

// MARK: - Swift Package Resolved Package Content Comparison Object

extension PackageResolvedFileDecodingTest {
    private var swiftPackageResolvedObject: ResolvedPackageContent {
        ResolvedPackageContent(
            object: .init(
                pins: [
                    .init(
                        package: "acknowlist",
                        repositoryURL: URL(string: "https://github.com/teufelaudio/AcknowList.git")!,
                        state: .init(
                            branch: "xcode-13",
                            revision: "cfaa05135ca7b625e2fc3c454e0ecff3529c2d25"
                        )
                    ),
                    .init(
                        package: "bridgemiddleware",
                        repositoryURL: URL(string: "https://github.com/SwiftRex/BridgeMiddleware")!,
                        state: .init(
                            revision: "6c886f95a877f7fb75bd7f4043a28d6880c5fff2",
                            version: "0.1.3"
                        )
                    ),
                    .init(
                        package: "combine-schedulers",
                        repositoryURL: URL(string: "https://github.com/pointfreeco/combine-schedulers")!,
                        state: .init(
                            revision: "9dc9cbe4bc45c65164fa653a563d8d8db61b09bb",
                            version: "1.0.0"
                        )
                    ),
                    .init(
                        package: "combinebonjour",
                        repositoryURL: URL(string: "https://github.com/teufelaudio/CombineBonjour.git")!,
                        state: .init(
                            revision: "d44454a4fa1944948b205f2dffec61b066361923",
                            version: "0.1.10"
                        )
                    ),
                    .init(
                        package: "combineexternalaccessory",
                        repositoryURL: URL(string: "https://github.com/teufelaudio/CombineExternalAccessory.git")!,
                        state: .init(
                            revision: "bab65b0be21e91bed9d3af7ee3569344fc265932",
                            version: "0.1.0"
                        )
                    )
                ]
            ),
            version: 2
        )
    }
}
