//
//  XCTestCase+MemoryLeakTracking.swift
//  Comic18_iOSTests
//
//  Created by Bang Chiang Liao on 2023/2/17.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackMemoryLeak(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
