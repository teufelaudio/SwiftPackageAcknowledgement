import Foundation

public protocol PackageFiltering {
    func ignoring(packages ignore: [String]) -> Self
}

public struct ResolvedPackage: Decodable, Equatable {
    let package: String
    let repositoryURL: URL
    let state: ResolvedPackageState
    
    public init(package: String, repositoryURL: URL, state: ResolvedPackageState) {
        self.package = package
        self.repositoryURL = repositoryURL
        self.state = state
    }
}

public struct ResolvedPackageState: Decodable, Equatable {
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
