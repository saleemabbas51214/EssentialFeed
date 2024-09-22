//
//  CachedFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by abbas on 14.08.24.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(items: [FeedItem]) {
        store.deleteCachedItems()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedItems() {
        deleteCachedFeedCallCount += 1
    }
}

class CachedFeedUseCaseTests: XCTest {
    
    func test_doNot_Delete_CachedItem_On_Creation() {
        let (_ , store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()

        let items = [uniqueItem(), uniqueItem()]
        sut.save(items: items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    // MARK: Helpers
    private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}
