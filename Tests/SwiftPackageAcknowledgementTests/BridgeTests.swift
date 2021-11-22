import Models
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
            )
        ]
        let content = ResolvedPackageContent(
            object: ResolvedPackageObject(pins: pins),
            version: 1
        )
        
        // act
        let packageRepositories = extractPackageGitHubRepositories(from: content)
        
        // assert
        let repositories = packageRepositories.map(\.repository)
        let acknowListRepo = repositories[0]
        XCTAssertEqual(acknowListRepo.name, "AcknowList")
        XCTAssertEqual(acknowListRepo.owner, "vtourraine")

        let commanderRepo = repositories[1]
        XCTAssertEqual(commanderRepo.name, "Commander")
        XCTAssertEqual(commanderRepo.owner, "kylef")
    }
}
