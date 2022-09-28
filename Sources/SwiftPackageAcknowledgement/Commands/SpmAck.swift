// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import ArgumentParser

struct SpmAck: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Create Licensing Views from SwiftPackageManager Packages",
        subcommands: [CarthagePlist.self, SpmPlist.self, ManualPlist.self, GeneratePlist.self]
    )
}
