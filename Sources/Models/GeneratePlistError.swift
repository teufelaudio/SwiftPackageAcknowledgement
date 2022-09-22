// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import Foundation

public enum GeneratePlistError: Error {
    case workspacePathDoesNotExist
    case workspacePathIsNotAFolder
    case carthageResolvePathDoesNotExist
    case invalidCarthageResolvePath
    case swiftPackageNotPresent
    case packageResolvedFileCannotBeOpen(Error?)
    case swiftPackageJsonCannotBeDecoded(Error)
    case jsonPathDoesNotExist
    case invalidJsonPath
    case invalidLicenseMetadataURL
    case unknownRepository
    case invalidCarthagePackage(String)
    case githubAPIURLError(URLError)
    case githubLicenseNotFound
    case githubAPIBudgetExceeded
    case githubAPIInvalidResponse(URLResponse)
    case githubLicenseJsonCannotBeDecoded(url: URL, json: String?, error: Error)
    case githubLicenseCannotBeDownloaded(URL)
    case cocoaPodsPListCannotBeEncoded(Error)
}
