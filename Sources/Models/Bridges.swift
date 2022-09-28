// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import Combine
import Foundation
import FoundationExtensions
import Helper

public typealias PackageRepository = (package: ResolvedPackage, repository: GitHubRepository)
public typealias PackageLicense = (package: ResolvedPackage, license: GitHubLicense)

public func extractPackageGitHubRepositories(from packages: [ResolvedPackage]) -> [PackageRepository] {
    packages.compactMap { spmPackage in
        guard let repository = githubRepository(from: spmPackage.repositoryURL).value else {
            print("⚠️ Ignoring project \(spmPackage.package) because we don't know how to fetch the license from it")
            return nil
        }

        return PackageRepository(package: spmPackage, repository: repository)
    }
}

public func fetchGithubLicenses(
    packageRepositories: [PackageRepository],
    githubClientID: String?,
    githubClientSecret: String?
) -> Reader<(Request, Decoder<GitHubLicense>), Publishers.Promise<[PackageLicense], GeneratePlistError>> {
    Reader { requester, decoder in
        Publishers.Promise.zip(
            packageRepositories.map { packageRepository -> Publishers.Promise<PackageLicense?, GeneratePlistError> in
                githubLicensingAPI(
                    repository: packageRepository.repository,
                    githubClientID: githubClientID,
                    githubClientSecret: githubClientSecret
                )
                .inject((requester, decoder))
                .map { license in PackageLicense(package: packageRepository.package, license: license) }
                .catch { error in
                    // Some special errors we allow to go through, so this specific package will be removed
                    // from the final plist, but the others will be there. Example of that: when one repo doesn't
                    // have the LICENSES file (404), we just log to the console a message similar to the one for
                    // wrong URLs.
                    //
                    // Other cases, such as 403 for example, we want to interrupt the process completely, because
                    // we exceeded the Github API budget and none of the licenses from now on will succeed.
                    //
                    // These are two different levels of errors.

                    if case .githubLicenseNotFound = error {
                        print("⚠️ Ignoring project \(packageRepository.package.package) becuse we failed to download the LICENSE from github. Error: \(error)")

                        // Return a nil PackageLicense for now, we filter them out in the last step (outside the Promise.zip)
                        return .init(value: nil)
                    }
                    return .init(error: error)
                }
            }
        ).map { arrayOfOptionalPackages in
            // Remove nil packages, that felt in the case of "soft" error (see comments above)
            arrayOfOptionalPackages.compactMap(identity)
        }
    }
}

public func cocoaPodsModel(packageLicenses: [PackageLicense]) -> Reader<Request, Publishers.Promise<CocoaPodsPlist, GeneratePlistError>> {
    Reader { requester in
        Publishers.Promise.zip(
            packageLicenses.map { packageLicense in
                downloadGitHubLicenseFile(url: packageLicense.license.downloadUrl)
                    .inject(requester)
                    .map { footerText in
                        CocoaPodsPlist.Item(title: packageLicense.package.package, license: packageLicense.license.licenseName, footerText: footerText)
                    }
            }
        )
        .map(CocoaPodsPlist.init)
    }
}
