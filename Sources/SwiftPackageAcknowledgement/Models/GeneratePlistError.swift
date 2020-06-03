//
//  GeneratePlistError.swift
//  SwiftPackageAcknowledgement
//
//  Created by Luiz Barbosa on 03.06.20.
//  Copyright © 2020 Lautsprecher Teufel GmbH. All rights reserved.
//

import Foundation

enum GeneratePlistError: Error {
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
