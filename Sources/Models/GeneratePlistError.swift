// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import Foundation

public enum GeneratePlistError: Error {
    case workspacePathDoesNotExist
    case workspacePathIsNotAFolder
    case swiftPackageNotPresent
    case swiftPackageCannotBeOpen(Error)
    case swiftPackageJsonCannotBeDecoded(Error)
    case invalidLicenseMetadataURL
    case unknownRepository
    case githubAPIURLError(URLError)
    case githubAPIInvalidResponse(URLResponse)
    case githubLicenseJsonCannotBeDecoded(url: URL, json: String?, error: Error)
    case githubLicenseCannotBeDownloaded(URL)
    case cocoaPodsPListCannotBeEncoded(Error)
}
