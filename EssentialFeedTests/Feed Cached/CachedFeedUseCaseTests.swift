//
//  CachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by abbas on 14.08.24.
//

import XCTest

class LocalFeedLoader {
    let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
}

class FeedStore {
    let deleteCachedFeedCallCount = 0
}

class CachedFeedUseCaseTests: XCTest {
    
    func test_doNot_Delete_CachedItem_On_Creation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
}
