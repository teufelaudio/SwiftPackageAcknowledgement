//
//  SpmAck.swift
//  SwiftPackageAcknowledgement
//
//  Created by Luiz Barbosa on 03.06.20.
//  Copyright © 2020 Lautsprecher Teufel GmbH. All rights reserved.
//

import ArgumentParser

struct SpmAck: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Create Licensing Views from SwiftPackageManager Packages",
        subcommands: [GeneratePlist.self]
    )
}
