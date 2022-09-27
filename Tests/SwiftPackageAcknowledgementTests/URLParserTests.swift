import Models
import XCTest

class URLParserTests: XCTestCase {
    func test_spm_file_path_parser_for_full_path() throws {
        let argument = "/Users/my-user/projects/my-project/Workspace.xcworkspace"
        let alwaysTruePathExists: (String) -> (exists: Bool, isFolder: Bool) = { path in (exists: true, isFolder: !path.hasSuffix(".resolved")) }
        let result: Result<URL, GeneratePlistError> = packageResolvedFile(from: argument).inject(alwaysTruePathExists)

        XCTAssertEqual("file:///Users/my-user/projects/my-project/Workspace.xcworkspace/xcshareddata/swiftpm/Package.resolved", result.value?.absoluteString)
    }
    
    func test_spm_file_path_parser_for_relative_path() throws {
        let argument = "Workspace.xcworkspace"
        let alwaysTruePathExists: (String) -> (exists: Bool, isFolder: Bool) = { path in (exists: true, isFolder: !path.hasSuffix(".resolved")) }
        let result: Result<URL, GeneratePlistError> = packageResolvedFile(from: argument).inject(alwaysTruePathExists)

        XCTAssertTrue(result.value?.absoluteString.hasPrefix("file:///") == true)
        XCTAssertTrue(result.value?.absoluteString.hasSuffix("/Workspace.xcworkspace/xcshareddata/swiftpm/Package.resolved") == true)
    }

    func test_spm_file_path_parser_for_user_path() throws {
        let argument = "~/projects/my-project/Workspace.xcworkspace"
        let alwaysTruePathExists: (String) -> (exists: Bool, isFolder: Bool) = { path in (exists: true, isFolder: !path.hasSuffix(".resolved")) }
        let result: Result<URL, GeneratePlistError> = packageResolvedFile(from: argument).inject(alwaysTruePathExists)

        XCTAssertTrue(result.value?.absoluteString.hasPrefix("file:///Users/") == true)
        XCTAssertTrue(result.value?.absoluteString.hasSuffix("/Workspace.xcworkspace/xcshareddata/swiftpm/Package.resolved") == true)
    }

    func test_carthage_file_path_parser_for_full_path() throws {
        let argument = "/Users/my-user/projects/my-project/Cartfile.resolved"
        let alwaysTruePathExists: (String) -> (exists: Bool, isFolder: Bool) = { path in (exists: true, isFolder: !path.hasSuffix(".resolved")) }
        let result: Result<URL, GeneratePlistError> = carthageResolvedFile(from: argument).inject(alwaysTruePathExists)

        XCTAssertEqual("file:///Users/my-user/projects/my-project/Cartfile.resolved", result.value?.absoluteString)
    }
    
    func test_carthage_file_path_parser_for_relative_path() throws {
        let argument = "Cartfile.resolved"
        let alwaysTruePathExists: (String) -> (exists: Bool, isFolder: Bool) = { path in (exists: true, isFolder: !path.hasSuffix(".resolved")) }
        let result: Result<URL, GeneratePlistError> = carthageResolvedFile(from: argument).inject(alwaysTruePathExists)

        XCTAssertTrue(result.value?.absoluteString.hasPrefix("file:///") == true)
        XCTAssertTrue(result.value?.absoluteString.hasSuffix("/Cartfile.resolved") == true)
    }

    func test_carthage_file_path_parser_for_user_path() throws {
        let argument = "~/projects/my-project/Cartfile.resolved"
        let alwaysTruePathExists: (String) -> (exists: Bool, isFolder: Bool) = { path in (exists: true, isFolder: !path.hasSuffix(".resolved")) }
        let result: Result<URL, GeneratePlistError> = carthageResolvedFile(from: argument).inject(alwaysTruePathExists)

        XCTAssertTrue(result.value?.absoluteString.hasPrefix("file:///Users/") == true)
        XCTAssertTrue(result.value?.absoluteString.hasSuffix("/Cartfile.resolved") == true)
    }

}
