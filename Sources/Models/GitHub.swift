// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import Combine
import Foundation
import FoundationExtensions
import Helper

public typealias GitHubRepository = (owner: String, name: String)

public struct GitHubLicense: Decodable {
    public let name: String
    public let path: String
    public let sha: String
    public let size: Int
    public let url: URL?
    public let htmlUrl: URL?
    public let gitUrl: URL?
    public let downloadUrl: URL
    public let type: String?
    public let content: String?
    public let encoding: String?
    public let license: LicenseDetails

    public var licenseName: String {
        license.name
    }

    public struct LicenseDetails: Decodable {
        public let key: String
        public let name: String
        public let spdxId: String?
        public let url: URL?
        public let nodeId: String?
    }
}

func githubRepository(from url: URL) -> Result<GitHubRepository, GeneratePlistError> {
    let gitDomain = "github.com"
    let gitSuffix = ".git"

    guard let host = url.host,
        host.contains(gitDomain),
        url.pathComponents.count >= 2,
        let lastPathComponent = url.pathComponents.last
    else { return .failure(.unknownRepository) }

    guard let owner = url.pathComponents[safe: 1], !owner.isEmpty else {
        return .failure(.invalidLicenseMetadataURL)
    }
    let name = lastPathComponent.contains(gitSuffix)
        ? String(lastPathComponent.dropLast(gitSuffix.count))
        : String(lastPathComponent.replacingOccurrences(of: gitSuffix, with: ""))
    
    return .success(
        GitHubRepository(
            owner: owner,
            name: name
        )
    )
}

public func githubLicensingAPI(
    repository: GitHubRepository,
    githubClientID: String?,
    githubClientSecret: String?
) -> Reader<(Request, Decoder<GitHubLicense>), Publishers.Promise<GitHubLicense, GeneratePlistError>> {
    guard let url = URL(string: "https://api.github.com/repos/\(repository.owner)/\(repository.name)/license") else {
        return Reader { _ in .init(error: .invalidLicenseMetadataURL) }
    }

    var request = URLRequest(url: url)
    zip(githubClientID, githubClientSecret)
        .flatMap { (clientId, clientSecret) in "\(clientId):\(clientSecret)".data(using: .utf8) }
        .map { "Basic \($0.base64EncodedString())" }
        .analysis(ifSome: { request.addValue($0, forHTTPHeaderField: "Authorization") }, ifNone: { })

    print("Fetching from \(url)")

    return Reader { requester, decoder in
        requester(request)
            .mapError(GeneratePlistError.githubAPIURLError)
            .flatMapResult { data, response -> Result<Data, GeneratePlistError> in
                guard let httpResponse = response as? HTTPURLResponse,
                    200..<300 ~= httpResponse.statusCode else {
                        return .failure(.githubAPIInvalidResponse(response))
                }
                return .success(data)
            }
            .flatMapResult { data in
                decoder(data).mapError { error in
                    GeneratePlistError.githubLicenseJsonCannotBeDecoded(url: url, json: String(data: data, encoding: .utf8), error: error)
                }
            }
            .promise
    }
}

public func downloadGitHubLicenseFile(url: URL) -> Reader<Request, Publishers.Promise<String, GeneratePlistError>> {
    Reader { requester in
        requester(URLRequest(url: url))
            .mapError(GeneratePlistError.githubAPIURLError)
            .flatMapResult { data, response -> Result<Data, GeneratePlistError> in
                guard let httpResponse = response as? HTTPURLResponse,
                    200..<300 ~= httpResponse.statusCode else {
                        return .failure(.githubAPIInvalidResponse(response))
                }
                return .success(data)
        }
        .flatMapResult { data in
            String(data: data, encoding: .utf8).map(Result.success) ?? .failure(GeneratePlistError.githubLicenseCannotBeDownloaded(url))
        }
        .promise
    }
}
