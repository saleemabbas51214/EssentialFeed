//
//  XCTestCase+MemoryLeaksTracking.swift
//  EssentialFeedTests
//
//  Created by abbas on 31.03.24.
//
import XCTest

extension XCTestCase {
     func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
