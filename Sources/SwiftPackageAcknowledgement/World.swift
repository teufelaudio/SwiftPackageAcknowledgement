// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import Combine
import Foundation

typealias Request = (URLRequest) -> Publishers.Promise<(data: Data, response: URLResponse), URLError>

typealias Decoder<T> = (Data) -> Result<T, Error>
typealias Encoder<T> = (T) -> Result<Data, Error>

typealias PathExists = (String) -> (exists: Bool, isFolder: Bool)
typealias FileSave = (String, Data) -> Result<Void, Error>

struct World {
    let urlSession: Request

    let spmJsonDecoder: Decoder<ResolvedPackageContent>
    let githubJsonDecoder: Decoder<GitHubLicense>
    let cocoaPodsEncoder: Encoder<CocoaPodsPlist>

    let pathExists: PathExists
    let fileSave: FileSave
}

extension World {
    static var `default`: World = .init(
        urlSession: { URLSession.shared.dataTaskPublisher(for: $0).promise },

        spmJsonDecoder: { data in
            Result { try JSONDecoder().decode(ResolvedPackageContent.self, from: data) }
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
