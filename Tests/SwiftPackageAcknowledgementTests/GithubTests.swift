// Copyright © 2021 Lautsprecher Teufel GmbH. All rights reserved.

import Foundation

import Models
import XCTest

class GithubTests: XCTestCase {
    func test_github_license_decode() throws {
        let data = try XCTUnwrap(json.data(using: .utf8))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let sut = try decoder.decode(GitHubLicense.self, from: data)
        XCTAssertEqual(sut.name, "LICENSE")
        XCTAssertEqual(sut.path, "LICENSE")
        XCTAssertEqual(sut.sha, "261eeb9e9f8b2b4b0d119366dda99c6fd7d35c64")
        XCTAssertEqual(sut.size, 11357)
        XCTAssertEqual(sut.url, try XCTUnwrap(URL(string: "https://api.github.com/repos/SwiftRex/SwiftRex/contents/LICENSE?ref=develop")))
        XCTAssertEqual(sut.htmlUrl, try XCTUnwrap(URL(string: "https://github.com/SwiftRex/SwiftRex/blob/develop/LICENSE")))
        XCTAssertEqual(sut.gitUrl, try XCTUnwrap(URL(string: "https://api.github.com/repos/SwiftRex/SwiftRex/git/blobs/261eeb9e9f8b2b4b0d119366dda99c6fd7d35c64")))
        XCTAssertEqual(sut.downloadUrl, try XCTUnwrap(URL(string: "https://raw.githubusercontent.com/SwiftRex/SwiftRex/develop/LICENSE")))
        XCTAssertEqual(sut.type, "file")
        XCTAssertEqual(sut.content, "GVyIHRoZSBMaWNlbnNlLgo=\n")
        XCTAssertEqual(sut.encoding, "base64")
        XCTAssertEqual(sut.license.key, "apache-2.0")
        XCTAssertEqual(sut.license.name, "Apache License 2.0")
        XCTAssertEqual(sut.license.spdxId, "Apache-2.0")
        XCTAssertEqual(sut.license.url, try XCTUnwrap(URL(string: "https://api.github.com/licenses/apache-2.0")))
        XCTAssertEqual(sut.license.nodeId, "MDc6TGljZW5zZTI=")
    }
}


let json =
"""
{
  "name": "LICENSE",
  "path": "LICENSE",
  "sha": "261eeb9e9f8b2b4b0d119366dda99c6fd7d35c64",
  "size": 11357,
  "url": "https://api.github.com/repos/SwiftRex/SwiftRex/contents/LICENSE?ref=develop",
  "html_url": "https://github.com/SwiftRex/SwiftRex/blob/develop/LICENSE",
  "git_url": "https://api.github.com/repos/SwiftRex/SwiftRex/git/blobs/261eeb9e9f8b2b4b0d119366dda99c6fd7d35c64",
  "download_url": "https://raw.githubusercontent.com/SwiftRex/SwiftRex/develop/LICENSE",
  "type": "file",
  "content": "GVyIHRoZSBMaWNlbnNlLgo=\\n",
  "encoding": "base64",
  "_links": {
    "self": "https://api.github.com/repos/SwiftRex/SwiftRex/contents/LICENSE?ref=develop",
    "git": "https://api.github.com/repos/SwiftRex/SwiftRex/git/blobs/261eeb9e9f8b2b4b0d119366dda99c6fd7d35c64",
    "html": "https://github.com/SwiftRex/SwiftRex/blob/develop/LICENSE"
  },
  "license": {
    "key": "apache-2.0",
    "name": "Apache License 2.0",
    "spdx_id": "Apache-2.0",
    "url": "https://api.github.com/licenses/apache-2.0",
    "node_id": "MDc6TGljZW5zZTI="
  }
}
"""
