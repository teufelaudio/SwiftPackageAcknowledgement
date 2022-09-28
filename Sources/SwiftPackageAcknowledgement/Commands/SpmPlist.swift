// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import ArgumentParser
import Combine
import Foundation
import FoundationExtensions
import Models

struct SpmPlist: ParsableCommand {

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
        
        extractPackagesForSPM(workspacePath: workspacePath, ignore: ignore)
            .flatMap { writePlist(for: $0, gitClientID: gitClientID, gitSecret: gitSecret, outputPath: outputFile) }
            .inject(world)
            .executeAndWait(storeIn: &cancellables)
    }
}
