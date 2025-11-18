//
//  Utils.swift
//  RapidSplitTests
//
//  Created by Addison Hanrattie on 11/18/25.
//

import Foundation

var IS_RUNNING_IN_CLOUD: Bool {
    return ProcessInfo.processInfo.environment["CI"] != nil
}
