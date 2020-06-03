//
//  Bridges.swift
//  SwiftPackageAcknowledgement
//
//  Created by Luiz Barbosa on 03.06.20.
//  Copyright © 2020 Lautsprecher Teufel GmbH. All rights reserved.
//

import Combine
import Foundation
import FoundationExtensions

typealias PackageRepository = (package: ResolvedPackage, repository: GitHubRepository)
typealias PackageLicense = (package: ResolvedPackage, license: GitHubLicense)

func extractPackageGitHubRepositories(from spmFile: ResolvedPackageContent) -> [PackageRepository] {
    spmFile.object.pins.compactMap { spmPackage in
        guard let repository = githubRepository(from: spmPackage.repositoryURL).value else {
            print("Ignoring project \(spmPackage.package) because we don't know how to fetch the license from it")
            return nil
        }

        return PackageRepository(package: spmPackage, repository: repository)
    }
}

func fetchGithubLicenses(urlSession: @escaping Request,
                         decoder: @escaping Decoder<GitHubLicense>,
                         packageRepositories: [PackageRepository],
                         githubClientID: String?,
                         githubClientSecret: String?) -> Publishers.Promise<[PackageLicense], GeneratePlistError> {
    Publishers.Promise.zip(
        packageRepositories.map { packageRepository in
            githubLicensingAPI(
                urlSession: urlSession,
                decoder: decoder,
                repository: packageRepository.repository,
                githubClientID: githubClientID,
                githubClientSecret: githubClientSecret
            ).map { license in PackageLicense(package: packageRepository.package, license: license) }
            .promise
        }
    ).promise
}

func cocoaPodsModel(urlSession: @escaping Request, packageLicenses: [PackageLicense]) -> Publishers.Promise<CocoaPodsPlist, GeneratePlistError> {
    packageLicenses.traverse { packageLicense in
        downloadGitHubLicenseFile(urlSession: urlSession, url: packageLicense.license.downloadUrl)
            .map { footerText in
                CocoaPodsPlist.Item(title: packageLicense.package.package, license: packageLicense.license.licenseName, footerText: footerText)
            }
    }
    .map(CocoaPodsPlist.init)
    .promise
}
