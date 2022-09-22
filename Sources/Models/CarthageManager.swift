import Foundation
import FoundationExtensions
import Helper

public struct CarthageResolvedPackageContent: Decodable, Equatable {
    public let binaries: [String]
    public let packages: [ResolvedPackage]
    
    public init(binaries: [String], packages: [ResolvedPackage]) {
        self.binaries = binaries
        self.packages = packages
    }
}

extension CarthageResolvedPackageContent: PackageFiltering {
    public func ignoring(packages ignore: [String]) -> CarthageResolvedPackageContent {
        CarthageResolvedPackageContent(
            binaries: binaries.filter { binary in
                !ignore.contains { ignoredString in binary.contains(ignoredString) }
            },
            packages: packages.filter { pin in
                !ignore.contains(pin.package)
            }
        )
    }
}

public func carthageResolvedFile(from path: String) -> Reader<PathExists, Result<URL, GeneratePlistError>> {
    Reader { pathExists in
        let (exists, isDirectory) = pathExists(path)
        guard exists else { return .failure(.carthageResolvePathDoesNotExist) }
        guard !isDirectory else { return .failure(.invalidCarthageResolvePath) }

        let packageResolved = URL(fileURLWithPath: path, isDirectory: false)

        guard pathExists(packageResolved.path) == (exists: true, isDirectory: false) else {
            return .failure(.invalidCarthageResolvePath)
        }

        return .success(packageResolved)
    }
}

public func readCarthagePackageResolved(url: URL) -> Result<CarthageResolvedPackageContent, GeneratePlistError> {
    Result { try Data(contentsOf: url) }
        .mapError(GeneratePlistError.packageResolvedFileCannotBeOpen)
        .flatMap(readCarthagePackageResolved(data:))
}

public func readCarthagePackageResolved(data: Data) -> Result<CarthageResolvedPackageContent, GeneratePlistError> {
    guard let string = String(data: data, encoding: .utf8) else { return .failure(.packageResolvedFileCannotBeOpen(nil)) }
    let lines = string.components(separatedBy: .newlines)
    let binaries: [String] = lines.filter { $0.starts(with: "binary ") }.map { String($0.dropFirst("binary ".count)) }
    return lines
        .filter { $0.starts(with: "github ") }
        .map { (githubLine: String) -> Result<ResolvedPackage, GeneratePlistError> in
            let parts = githubLine.components(separatedBy: .whitespaces)
            guard parts.count == 3 else { return .failure(.invalidCarthagePackage(githubLine)) }
            guard let packageName = parts[safe: 1]?.replacingOccurrences(of: "\"", with: "").components(separatedBy: "/")[safe: 1] else {
                return .failure(.invalidCarthagePackage(githubLine))
            }
            guard let packageURL = (parts[safe: 1]?.replacingOccurrences(of: "\"", with: "")).flatMap({ URL(string: "https://github.com/\($0).git") }) else {
                return .failure(.invalidCarthagePackage(githubLine))
            }
            guard let packageVersion = parts[safe: 2]?.replacingOccurrences(of: "\"", with: "") else {
                return .failure(.invalidCarthagePackage(githubLine))
            }
            
            return .success(.init(package: packageName, repositoryURL: packageURL, state: .init(branch: nil, revision: nil, version: packageVersion)))
        }
        .traverse(identity)
        .map { resolvedPackages in
            CarthageResolvedPackageContent(binaries: binaries, packages: resolvedPackages)
        }
}
