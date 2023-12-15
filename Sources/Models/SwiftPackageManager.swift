// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import Foundation
import FoundationExtensions
import Helper

public struct ResolvedPackageContent: Decodable {
    let object: ResolvedPackageObject
    let version: Int
    
    public init(object: ResolvedPackageObject, version: Int) {
        self.object = object
        self.version = version
    }
}

extension ResolvedPackageContent: Equatable {}

// MARK: ResolvedPackageContent Decoding

extension ResolvedPackageContent {
    private enum CodingKeys: String, CodingKey {
        case object, version, pins
    }
    
    public init(from decoder: Swift.Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.object) {
            // we assume this is a resolved file from a xcworkspace
            object = try container.decode(ResolvedPackageObject.self, forKey: .object)
            version = try container.decode(Int.self, forKey: .version)
        } else {
            // we assume this is a resolved file from a package itself
            let pins = try container.decode([SwiftPackageResolvedPackage].self, forKey: .pins)
            object = ResolvedPackageObject(pins: pins.map {
                ResolvedPackage(package: $0.identity, repositoryURL: $0.location, state: $0.state)
            })
            version = try container.decode(Int.self, forKey: .version)
        }
    }
}

public extension ResolvedPackageContent {
    func ignoring(packages ignore: [String]) -> ResolvedPackageContent {
        if ignore.count == 0 { return self }
        return ResolvedPackageContent(
            object: ResolvedPackageObject(
                pins: object.pins.filter { pin in
                    !ignore.contains(pin.package)
                }
            ),
            version: version
        )
    }
}

public struct ResolvedPackageObject: Decodable {
    let pins: [ResolvedPackage]

    public init(pins: [ResolvedPackage]) {
        self.pins = pins
    }
}

extension ResolvedPackageObject: Equatable {}

// MARK: XCWorkspace ResolvedPackage

public struct ResolvedPackage: Decodable {
    let package: String
    let repositoryURL: URL
    let state: ResolvedPackageState
    
    public init(package: String, repositoryURL: URL, state: ResolvedPackageState) {
        self.package = package
        self.repositoryURL = repositoryURL
        self.state = state
    }
}

extension ResolvedPackage: Equatable {}

// MARK: Swift Package ResolvedPackage

public struct SwiftPackageResolvedPackage: Decodable {
    let identity: String
    let location: URL
    let state: ResolvedPackageState
}

public struct ResolvedPackageState: Decodable {
    let branch: String?
    let revision: String?
    let version: String?

    public init(
        branch: String? = nil,
        revision: String? = nil,
        version: String? = nil
    ) {
        self.branch = branch
        self.revision = revision
        self.version = version
    }
}

extension ResolvedPackageState: Equatable {}

public func packageResolvedFile(from path: String) -> Reader<PathExists, Result<URL, GeneratePlistError>> {
    Reader { pathExists in
        let (exists, isDirectory) = pathExists(path)
        guard exists else { return .failure(.workspacePathDoesNotExist) }
        guard isDirectory else { return .failure(.workspacePathIsNotAFolder) }

        // checks for a package resolved file within a workspace
        
        let workspaceURL = URL(fileURLWithPath: path, isDirectory: true)
        let workspacePackageResolved = workspaceURL
            .appendingPathComponent("xcshareddata", isDirectory: true)
            .appendingPathComponent("swiftpm", isDirectory: true)
            .appendingPathComponent("Package.resolved", isDirectory: false)

        if pathExists(workspacePackageResolved.path) == (exists: true, isDirectory: false) {
            return .success(workspacePackageResolved)
        }
        
        // checks for a package resolved file of a SwiftPackage
        
        let swiftPackageURL = URL(fileURLWithPath: path, isDirectory: true)
        let swiftPackageResolved = swiftPackageURL
            .appendingPathComponent("Package.resolved", isDirectory: false)
        
        if pathExists(swiftPackageResolved.path) == (exists: true, isDirectory: false) {
            return .success(swiftPackageResolved)
        }

        return .failure(.swiftPackageNotPresent)
    }
}

public func readSwiftPackageResolvedJson(url: URL) -> Reader<Decoder<ResolvedPackageContent>, Result<ResolvedPackageContent, GeneratePlistError>> {
    Reader { decoder in
        Result { try Data(contentsOf: url) }
            .mapError(GeneratePlistError.swiftPackageCannotBeOpen)
            .flatMap { decoder($0).mapError(GeneratePlistError.swiftPackageJsonCannotBeDecoded) }
    }
}
