// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import Combine
import Foundation
import Helper
import Models

struct World {
    let urlSession: Request

    let spmJsonDecoder: Decoder<SpmResolvedPackageContent>
    let manualJsonDecoder: Decoder<JsonResolvedPackageContent>
    let githubJsonDecoder: Decoder<GitHubLicense>
    let cocoaPodsEncoder: Encoder<CocoaPodsPlist>

    let pathExists: PathExists
    let fileSave: FileSave
}

extension World {
    static var `default`: World = .init(
        urlSession: { URLSession.shared.dataTaskPublisher(for: $0).promise },

        spmJsonDecoder: { data in
            Result { try JSONDecoder().decode(SpmResolvedPackageContent.self, from: data) }
        },
        manualJsonDecoder: { data in
            Result { try JSONDecoder().decode(JsonResolvedPackageContent.self, from: data) }
        },
        githubJsonDecoder: { data in
            Result {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(GitHubLicense.self, from: data)
            }
        },
        cocoaPodsEncoder: { cocoaPods in
            Result {
                let encoder = PropertyListEncoder()
                encoder.outputFormat = .xml
                return try encoder.encode(cocoaPods)
            }
        },

        pathExists: { path in
            var isFolder: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isFolder)
            return (exists: exists, isFolder: isFolder.boolValue)
        },

        fileSave: { path, data in
            FileManager.default.createFile(atPath: path, contents: data)
                ? Result.success(())
                : Result.failure(NSError(domain: "Can't write file at path \(path)", code: -1, userInfo: nil))
        }
    )
}
