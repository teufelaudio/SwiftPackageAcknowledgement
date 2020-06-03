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

func fetchGithubLicenses(
    packageRepositories: [PackageRepository],
    githubClientID: String?,
    githubClientSecret: String?
) -> Reader<(Request, Decoder<GitHubLicense>), Publishers.Promise<[PackageLicense], GeneratePlistError>> {
    Reader { requester, decoder in
        Publishers.Promise.zip(
            packageRepositories.map { packageRepository in
                githubLicensingAPI(
                    repository: packageRepository.repository,
                    githubClientID: githubClientID,
                    githubClientSecret: githubClientSecret
                )
                .inject((requester, decoder))
                .map { license in PackageLicense(package: packageRepository.package, license: license) }
                .promise
            }
        ).promise
    }
}

func cocoaPodsModel(packageLicenses: [PackageLicense]) -> Reader<Request, Publishers.Promise<CocoaPodsPlist, GeneratePlistError>> {
    Reader { requester in
        packageLicenses.traverse { packageLicense in
            downloadGitHubLicenseFile(url: packageLicense.license.downloadUrl)
                .inject(requester)
                .map { footerText in
                    CocoaPodsPlist.Item(title: packageLicense.package.package, license: packageLicense.license.licenseName, footerText: footerText)
            }
        }
        .map(CocoaPodsPlist.init)
        .promise
    }
}
