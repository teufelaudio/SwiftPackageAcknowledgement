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

extension String {
    func replacingOccurrences(of strings: [String], with newString: String) -> String {
        strings.reduce(self) { partialResult, itemToReplace in
            partialResult.replacingOccurrences(of: itemToReplace, with: newString)
        }
    }
}

func githubRepository(from url: URL) -> Result<GitHubRepository, GeneratePlistError> {
    let cleanupList = [
        "git@github.com:",
        "https://github.com/",
        "https://www.github.com/",
        "http://github.com/",
        "http://www.github.com/",
        ".git"
    ]
    
    let parts = url.absoluteString
        .replacingOccurrences(of: cleanupList, with: "")
        .split(separator: "/")
    
    guard
        let owner = parts[safe: 0].map(String.init),
        let name = parts[safe: 1].map(String.init)
    else { return .failure(.unknownRepository) }
    
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
