import Foundation
import FoundationExtensions
import Helper

public struct JsonResolvedPackageContent: Decodable {
    public let packages: [ResolvedPackage]

    public init(packages: [ResolvedPackage]) {
        self.packages = packages
    }
}

extension JsonResolvedPackageContent: PackageFiltering {
    public func ignoring(packages ignore: [String]) -> JsonResolvedPackageContent {
        JsonResolvedPackageContent(
            packages: packages.filter { pin in
                !ignore.contains(pin.package)
            }
        )
    }
}

public func jsonResolvedFile(from path: String) -> Reader<PathExists, Result<URL, GeneratePlistError>> {
    Reader { pathExists in
        let (exists, isDirectory) = pathExists(path)
        guard exists else { return .failure(.jsonPathDoesNotExist) }
        guard !isDirectory else { return .failure(.invalidJsonPath) }

        let packageResolved = URL(fileURLWithPath: path, isDirectory: false)

        guard pathExists(packageResolved.path) == (exists: true, isDirectory: false) else {
            return .failure(.invalidCarthageResolvePath)
        }

        return .success(packageResolved)
    }
}

public func readJsonPackage(url: URL) -> Reader<Decoder<JsonResolvedPackageContent>, Result<JsonResolvedPackageContent, GeneratePlistError>> {
    Reader { decoder in
        Result { try Data(contentsOf: url) }
            .mapError(GeneratePlistError.packageResolvedFileCannotBeOpen)
            .flatMap { decoder($0).mapError(GeneratePlistError.swiftPackageJsonCannotBeDecoded) }
    }
}
