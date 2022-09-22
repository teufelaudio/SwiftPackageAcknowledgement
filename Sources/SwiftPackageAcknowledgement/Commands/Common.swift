import Combine
import Foundation
import FoundationExtensions
import Models

func writePlist(for resolvedPackages: Result<[ResolvedPackage], GeneratePlistError>, gitClientID: String?, gitSecret: String?, outputPath: String)
-> Reader<World, AnyPublisher<Void, GeneratePlistError>> {
    Reader.pure(
        resolvedPackages
            .map(extractPackageGitHubRepositories)
            .promise
    )
    .flatMapPublisher {
        fetchGithubLicenses(
            packageRepositories: $0,
            githubClientID: gitClientID,
            githubClientSecret: gitSecret
        )
        .contramapEnvironment(\World.urlSession, \World.githubJsonDecoder)
    }
    .flatMapPublisher { (packageLicenses: [PackageLicense]) -> Reader<World, Publishers.Promise<CocoaPodsPlist, GeneratePlistError>> in
        cocoaPodsModel(packageLicenses: packageLicenses)
            .contramapEnvironment(\World.urlSession)
    }
    .flatMapPublisher { (cocoaPods: CocoaPodsPlist) -> Reader<World, Publishers.Promise<Void, GeneratePlistError>> in
        saveToPList(cocoaPods: cocoaPods, path: outputPath)
            .mapValue { result in result.promise }
            .contramapEnvironment(\World.fileSave, \World.cocoaPodsEncoder)
    }
}

func extractPackagesForSPM(workspacePath: String, ignore: String?) -> Reader<World, Result<[ResolvedPackage], GeneratePlistError>> {
    packageResolvedFile(from: workspacePath)
        .contramapEnvironment(\World.pathExists)
        .flatMapResult { readSwiftPackageResolvedJson(url: $0).contramapEnvironment(\World.spmJsonDecoder) }
        .mapResult { $0.ignoring(packages: (ignore ?? "").components(separatedBy: ",")).object.pins }
}

func extractPackagesForCarthage(cartfileResolvedPath: String, ignore: String?) -> Reader<World, Result<[ResolvedPackage], GeneratePlistError>> {
    carthageResolvedFile(from: cartfileResolvedPath)
        .contramapEnvironment(\World.pathExists)
        .flatMapResult { readCarthagePackageResolved(url: $0) }
        .mapResult { $0.ignoring(packages: (ignore ?? "").components(separatedBy: ",")).packages }
}

func extractPackagesForJSON(path: String, ignore: String?) -> Reader<World, Result<[ResolvedPackage], GeneratePlistError>> {
    jsonResolvedFile(from: path)
        .contramapEnvironment(\World.pathExists)
        .flatMapResult { readCarthagePackageResolved(url: $0) }
        .mapResult { $0.ignoring(packages: (ignore ?? "").components(separatedBy: ",")).packages }
}

extension Publisher where Failure == GeneratePlistError {
    func executeAndWait(storeIn cancellables: inout Set<AnyCancellable>) {
        sinkBlockingAndExit(
            receiveCompletion: { completion in
                switch completion {
                case let .failure(error):
                    Swift.print("\n💥 An error has occurred: \(error)")
                    if case .githubAPIBudgetExceeded = error {
                        Swift.print("Github API has a limit of 60 requests per hour when you don't use a Developer Token.")
                        Swift.print("Please consider going to https://github.com/settings/developers, creating an OAuth App and " +
                                    "providing Client ID and Client Secret Token in the script call.")
                    }
                case .finished:
                    Swift.print("\n✅ Done!")
                }
            },
            receiveValue: { _ in }
        )
        .store(in: &cancellables)

    }
}
