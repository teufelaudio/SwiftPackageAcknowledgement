// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import Foundation
import FoundationExtensions
import Helper

public struct SpmResolvedPackageContent: Decodable {
    public let object: SpmResolvedPackageObject
    public let version: Int
    
    public init(object: SpmResolvedPackageObject, version: Int) {
        self.object = object
        self.version = version
    }
}

extension SpmResolvedPackageContent: PackageFiltering {
    public func ignoring(packages ignore: [String]) -> SpmResolvedPackageContent {
        return SpmResolvedPackageContent(
            object: object.ignoring(packages: ignore),
            version: version
        )
    }
}

public struct SpmResolvedPackageObject: Decodable {
    public let pins: [ResolvedPackage]

    public init(pins: [ResolvedPackage]) {
        self.pins = pins
    }
}

extension SpmResolvedPackageObject: PackageFiltering {
    public func ignoring(packages ignore: [String]) -> SpmResolvedPackageObject {
        SpmResolvedPackageObject(
            pins: pins.filter { pin in
                !ignore.contains(pin.package)
            }
        )
    }
}

public func packageResolvedFile(from workspacePath: String) -> Reader<PathExists, Result<URL, GeneratePlistError>> {
    Reader { pathExists in
        let (exists, isDirectory) = pathExists(workspacePath)
        guard exists else { return .failure(.workspacePathDoesNotExist) }
        guard isDirectory else { return .failure(.workspacePathIsNotAFolder) }

        let workspaceURL = URL(fileURLWithPath: workspacePath, isDirectory: true)
        let packageResolved = workspaceURL
            .appendingPathComponent("xcshareddata", isDirectory: true)
            .appendingPathComponent("swiftpm", isDirectory: true)
            .appendingPathComponent("Package.resolved", isDirectory: false)

        guard pathExists(packageResolved.path) == (exists: true, isDirectory: false) else {
            return .failure(.swiftPackageNotPresent)
        }

        return .success(packageResolved)
    }
}

public func readSwiftPackageResolvedJson(url: URL) -> Reader<Decoder<SpmResolvedPackageContent>, Result<SpmResolvedPackageContent, GeneratePlistError>> {
    Reader { decoder in
        Result { try Data(contentsOf: url) }
            .mapError(GeneratePlistError.packageResolvedFileCannotBeOpen)
            .flatMap { decoder($0).mapError(GeneratePlistError.swiftPackageJsonCannotBeDecoded) }
    }
}
