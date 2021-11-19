// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import Combine
import Foundation
import FoundationExtensions
import Helper

public typealias GitHubRepository = (owner: String, name: String)

public struct GitHubLicense: Decodable {
    let name: String
    let path: String
    let sha: String
    let size: Int
    let url: URL?
    let htmlUrl: URL?
    let gitUrl: URL?
    let downloadUrl: URL
    let type: String?
    let content: String?
    let encoding: String?
    let license: LicenseDetails

    var licenseName: String {
        license.name
    }

    struct LicenseDetails: Decodable {
        let key: String
        let name: String
        let spdx_id: String?
        let url: URL?
        let node_id: String?
    }
}

public func githubRepository(from url: URL) -> Result<GitHubRepository, GeneratePlistError> {
    let gitDomain = "github.com"
    let gitSuffix = ".git"

    guard let host = url.host,
        host.contains(gitDomain),
        url.pathComponents.count >= 2,
        url.pathComponents[url.pathComponents.count - 1].hasSuffix(gitSuffix) else { return .failure(.unknownRepository) }

    return .success(
        GitHubRepository(
            owner: url.pathComponents[url.pathComponents.count - 2],
            name: String(url.pathComponents[url.pathComponents.count - 1].dropLast(gitSuffix.count))
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
        .flatMap { "\($0):\($0)".data(using: .utf8) }
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
