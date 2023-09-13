//
//  XCTestCase+MemoryLeak.swift
//  PlacesTests
//
//  Created by Andrei on 12/09/2023.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance was not deallocated", file: file, line: line)
        }
    }
}
