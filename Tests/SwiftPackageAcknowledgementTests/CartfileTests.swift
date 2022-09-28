import Models
import XCTest

class CartfileTests: XCTestCase {
    func test_cartfile_resolved_is_decoded() throws {
        let expectedPackages = try CarthageResolvedPackageContent(
            binaries: [
                "\"https://dl.google.com/dl/firebase/ios/carthage/FirebaseABTestingBinary.json\" \"8.15.0\"",
                "\"https://raw.githubusercontent.com/Appboy/appboy-ios-sdk/master/appboy_ios_sdk.json\" \"4.4.0\""
            ],
            packages: [
                ResolvedPackage(
                    package: "Alamofire",
                    repositoryURL: XCTUnwrap(URL(string: "https://github.com/Alamofire/Alamofire.git")),
                    state: .init(branch: nil, revision: nil, version: "5.4.1")
                ),
                ResolvedPackage(
                    package: "SwiftyJSON",
                    repositoryURL: XCTUnwrap(URL(string: "https://github.com/SwiftyJSON/SwiftyJSON.git")),
                    state: .init(branch: nil, revision: nil, version: "5.0.0")
                )
            ]
        )
        
        let sut = sampleFile.data(using: .utf8).map(readCarthagePackageResolved(data:)).flatMap { $0.value }
        XCTAssertEqual(sut, expectedPackages)
    }

    func test_cartfile_ignoring_binary() throws {
        let allPackages = try CarthageResolvedPackageContent(
            binaries: [
                "\"https://dl.google.com/dl/firebase/ios/carthage/FirebaseABTestingBinary.json\" \"8.15.0\"",
                "\"https://raw.githubusercontent.com/Appboy/appboy-ios-sdk/master/appboy_ios_sdk.json\" \"4.4.0\""
            ],
            packages: [
                ResolvedPackage(
                    package: "Alamofire",
                    repositoryURL: XCTUnwrap(URL(string: "https://github.com/Alamofire/Alamofire.git")),
                    state: .init(branch: nil, revision: nil, version: "5.4.1")
                ),
                ResolvedPackage(
                    package: "SwiftyJSON",
                    repositoryURL: XCTUnwrap(URL(string: "https://github.com/SwiftyJSON/SwiftyJSON.git")),
                    state: .init(branch: nil, revision: nil, version: "5.0.0")
                )
            ]
        )

        let expectedPackages = try CarthageResolvedPackageContent(
            binaries: [
                "\"https://raw.githubusercontent.com/Appboy/appboy-ios-sdk/master/appboy_ios_sdk.json\" \"4.4.0\""
            ],
            packages: [
                ResolvedPackage(
                    package: "Alamofire",
                    repositoryURL: XCTUnwrap(URL(string: "https://github.com/Alamofire/Alamofire.git")),
                    state: .init(branch: nil, revision: nil, version: "5.4.1")
                ),
                ResolvedPackage(
                    package: "SwiftyJSON",
                    repositoryURL: XCTUnwrap(URL(string: "https://github.com/SwiftyJSON/SwiftyJSON.git")),
                    state: .init(branch: nil, revision: nil, version: "5.0.0")
                )
            ]
        )

        let sut = allPackages.ignoring(packages: ["Firebase"])
        XCTAssertEqual(sut, expectedPackages)
    }

    func test_cartfile_ignoring_package() throws {
        let allPackages = try CarthageResolvedPackageContent(
            binaries: [
                "\"https://dl.google.com/dl/firebase/ios/carthage/FirebaseABTestingBinary.json\" \"8.15.0\"",
                "\"https://raw.githubusercontent.com/Appboy/appboy-ios-sdk/master/appboy_ios_sdk.json\" \"4.4.0\""
            ],
            packages: [
                ResolvedPackage(
                    package: "Alamofire",
                    repositoryURL: XCTUnwrap(URL(string: "https://github.com/Alamofire/Alamofire.git")),
                    state: .init(branch: nil, revision: nil, version: "5.4.1")
                ),
                ResolvedPackage(
                    package: "SwiftyJSON",
                    repositoryURL: XCTUnwrap(URL(string: "https://github.com/SwiftyJSON/SwiftyJSON.git")),
                    state: .init(branch: nil, revision: nil, version: "5.0.0")
                )
            ]
        )

        let expectedPackages = try CarthageResolvedPackageContent(
            binaries: [
                "\"https://dl.google.com/dl/firebase/ios/carthage/FirebaseABTestingBinary.json\" \"8.15.0\"",
                "\"https://raw.githubusercontent.com/Appboy/appboy-ios-sdk/master/appboy_ios_sdk.json\" \"4.4.0\""
            ],
            packages: [
                ResolvedPackage(
                    package: "SwiftyJSON",
                    repositoryURL: XCTUnwrap(URL(string: "https://github.com/SwiftyJSON/SwiftyJSON.git")),
                    state: .init(branch: nil, revision: nil, version: "5.0.0")
                )
            ]
        )

        let sut = allPackages.ignoring(packages: ["Alamofire"])
        XCTAssertEqual(sut, expectedPackages)
    }
}

let sampleFile = """
binary "https://dl.google.com/dl/firebase/ios/carthage/FirebaseABTestingBinary.json" "8.15.0"
binary "https://raw.githubusercontent.com/Appboy/appboy-ios-sdk/master/appboy_ios_sdk.json" "4.4.0"
github "Alamofire/Alamofire" "5.4.1"
github "SwiftyJSON/SwiftyJSON" "5.0.0"
"""
