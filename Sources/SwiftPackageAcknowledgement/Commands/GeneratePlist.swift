// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import ArgumentParser
import Combine
import Foundation
import FoundationExtensions
import Models

struct GeneratePlist: ParsableCommand {

    @Argument(help: "Path to your workspace, e.g. ~/code/MyProject/MyProject.xcworkspace")
    var workspacePath: String
    @Argument(help: "Path to the file to be created or replaced")
    var outputFile: String
    @Argument(help: "If providing client ID and client secret, the GitHub API call will have extended limits.")
    var gitClientID: String?
    @Argument(help: "If providing client ID and client secret, the GitHub API call will have extended limits.")
    var gitSecret: String?
    @Option(help: "Comma-separated list of libraries to ignore and not present on the generated plist file.")
    var ignore: String?

    private var world: World { .default }

    func run() throws {
        var cancellables = Set<AnyCancellable>()

        packageResolvedFile(from: workspacePath)
            .contramapEnvironment(\World.pathExists)
            .flatMapResult { readSwiftPackageResolvedJson(url: $0).contramapEnvironment(\World.spmJsonDecoder) }
            .mapResult { $0.ignoring(packages: (ignore ?? "").components(separatedBy: ",")) }
            .mapResult(extractPackageGitHubRepositories)
            .mapValue(\.promise)
            .flatMapPublisher { packageRepositories in
                fetchGithubLicenses(
                    packageRepositories: packageRepositories,
                    githubClientID: self.gitClientID,
                    githubClientSecret: self.gitSecret
                ).contramapEnvironment(\World.urlSession, \World.githubJsonDecoder)
            }
            .flatMapPublisher { (packageLicenses: [PackageLicense]) in
                cocoaPodsModel(packageLicenses: packageLicenses)
                    .contramapEnvironment(\World.urlSession)
            }
            .flatMapPublisher { cocoaPods in
                saveToPList(cocoaPods: cocoaPods, path: self.outputFile)
                    .mapValue(\.promise)
                    .contramapEnvironment(\World.fileSave, \World.cocoaPodsEncoder)
            }
            .inject(world)
            .sinkBlockingAndExit(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(error): print("An error has occurred: \(error)")
                    case .finished:           print("Done!")
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}
