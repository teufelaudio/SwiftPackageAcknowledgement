// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import ArgumentParser
import Combine
import Foundation
import FoundationExtensions
import Models

struct GeneratePlist: ParsableCommand {

    @Argument(help: "Path to your workspace, e.g. ~/code/MyProject/MyProject.xcworkspace")
    var workspacePath: String
    @Option(help: "Path to your Cartfile.resolved, e.g. ~/code/MyProject/Cartfile.resolved")
    var cartfileResolvedPath: String? // --cartfile-resolved-path=Cartfile.resolved
    @Option(help: "Path to a custom JSON file with dependencies, e.g. ~/code/MyProject/MyPackages.json")
    var manualJsonPath: String?  // --manual-json-path=AdditionalPackages.json -> {"packages":[{"package":"","repositoryURL":"","state":{"version": "1.2.3"}}]}
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

        extractPackagesForSPM(workspacePath: workspacePath, ignore: ignore)
            .flatMapResult { accumulatedPackages -> Reader<World, Result<[ResolvedPackage], GeneratePlistError>> in
                guard let cartfileResolvedPath = cartfileResolvedPath else { return Reader.pure(.success(accumulatedPackages)) }

                return extractPackagesForCarthage(cartfileResolvedPath: cartfileResolvedPath, ignore: ignore)
                    .mapResult { $0 + accumulatedPackages }
            }
            .flatMapResult { accumulatedPackages -> Reader<World, Result<[ResolvedPackage], GeneratePlistError>> in
                guard let manualJsonPath = manualJsonPath else { return Reader.pure(.success(accumulatedPackages)) }

                return extractPackagesForJSON(path: manualJsonPath, ignore: ignore)
                    .mapResult { $0 + accumulatedPackages }
            }
            .flatMap { writePlist(for: $0, gitClientID: gitClientID, gitSecret: gitSecret, outputPath: outputFile) }
            .inject(world)
            .executeAndWait(storeIn: &cancellables)
    }
    
}
