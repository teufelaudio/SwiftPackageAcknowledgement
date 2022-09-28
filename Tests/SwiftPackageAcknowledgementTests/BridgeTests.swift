// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

@testable import Models
import XCTest

class BridgeTests: XCTestCase {
    func test_githubRepository_create() {
        // arrange
        let pins: [ResolvedPackage] = [
            .init(
                package: "AcknowList",
                repositoryURL: URL(string: "https://github.com/vtourraine/AcknowList.git")!,
                state: .init()
            ),
            .init(
                package: "Commander",
                repositoryURL: URL(string: "https://github.com/kylef/Commander")!,
                state: .init()
            ),
            .init(
                package: "SwiftPackageAcknowledgement",
                repositoryURL: URL(string: "http://github.com/teufelaudio/SwiftPackageAcknowledgement")!,
                state: .init()
            ),
            .init(
                package: "FoundationExtensions",
                repositoryURL: URL(string: "https://www.github.com/teufelaudio/FoundationExtensions")!,
                state: .init()
            ),
            .init(
                package: "NetworkExtensions",
                repositoryURL: URL(string: "git@github.com:teufelaudio/NetworkExtensions.git")!,
                state: .init()
            )
        ]
        let content = SpmResolvedPackageContent(
            object: SpmResolvedPackageObject(pins: pins),
            version: 1
        )
        
        // act
        let packageRepositories = extractPackageGitHubRepositories(from: content.object.pins)
        
        // assert
        let repositories = packageRepositories.map(\.repository)
        XCTAssertEqual(repositories.count, 5)
        
        let acknowListRepo = repositories[0]
        XCTAssertEqual(acknowListRepo.name, "AcknowList")
        XCTAssertEqual(acknowListRepo.owner, "vtourraine")

        let commanderRepo = repositories[1]
        XCTAssertEqual(commanderRepo.name, "Commander")
        XCTAssertEqual(commanderRepo.owner, "kylef")

        let spmAckRepo = repositories[2]
        XCTAssertEqual(spmAckRepo.name, "SwiftPackageAcknowledgement")
        XCTAssertEqual(spmAckRepo.owner, "teufelaudio")

        let foundationExtRepo = repositories[3]
        XCTAssertEqual(foundationExtRepo.name, "FoundationExtensions")
        XCTAssertEqual(foundationExtRepo.owner, "teufelaudio")

        let networkExtRepo = repositories[4]
        XCTAssertEqual(networkExtRepo.name, "NetworkExtensions")
        XCTAssertEqual(networkExtRepo.owner, "teufelaudio")
    }
}
