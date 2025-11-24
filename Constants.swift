//
//  Constants.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 11/18/25.
//

import Foundation
import SwiftData

let GROUP_IDENTIFIER = "group.com.addisonhanrattie.RapidSplit"
let OPEN_SHARED_IMAGE_PATH = "open-shared-image"
let SHARED_IMAGE_FILE_NAME = "shared-image.jpg"
let SCHEMA_VERSION = Schema.Version(0, 1, 1)

#if DEBUG
enum LaunchArguments: String {
    case reset = "--clearSwiftData"
    case seed = "--seedSwiftData"
}
#endif
