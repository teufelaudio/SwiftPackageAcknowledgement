//
//  GeneratePlist.swift
//  SwiftPackageAcknowledgement
//
//  Created by Luiz Barbosa on 03.06.20.
//  Copyright © 2020 Lautsprecher Teufel GmbH. All rights reserved.
//

import ArgumentParser
import Combine
import Foundation
import FoundationExtensions

struct GeneratePlist: ParsableCommand {

    @Argument(help: "Path to your workspace, e.g. ~/code/MyProject/MyProject.xcworkspace")
    var workspacePath: String
    @Argument(help: "Path to the file to be created or replaced")
    var outputFile: String
    @Argument(help: "If providing client ID and client secret, the GitHub API call will have extended limits.")
    var gitClientID: String?
    @Argument(help: "If providing client ID and client secret, the GitHub API call will have extended limits.")
    var gitSecret: String?

    var world: World { .default }

    func run() throws {
        var cancellables = Set<AnyCancellable>()

        packageResolvedFile(from: workspacePath, pathExists: world.pathExists)
            .flatMap(readJson(decoder: world.spmJsonDecoder))
            .map(extractPackageGitHubRepositories)
            .promise
            .flatMap { packageRepositories in
                fetchGithubLicenses(
                    urlSession: self.world.urlSession,
                    decoder: self.world.githubJsonDecoder,
                    packageRepositories: packageRepositories,
                    githubClientID: self.gitClientID,
                    githubClientSecret: self.gitSecret
                )
            }
            .flatMap { (packageLicenses: [PackageLicense]) in
                cocoaPodsModel(urlSession: self.world.urlSession, packageLicenses: packageLicenses)
            }.flatMapResult { cocoaPods in
                saveToPList(fileSave: self.world.fileSave, encoder: self.world.cocoaPodsEncoder, cocoaPods: cocoaPods, path: self.outputFile)
            }.sinkBlockingAndExit(
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
