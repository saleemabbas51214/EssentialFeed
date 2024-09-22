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
    private let currentDate: () -> Date

    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(items: [FeedItem]) {
        store.deleteCachedItems { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                store.insert(items, timestamp: currentDate())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCachedFeedCallCount = 0
    var insertCallCount = 0
    
    private var deletionCompletion = [DeletionCompletion]()
    var insertions = [(items: [FeedItem], timestamp: Date)]()

    func deleteCachedItems(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCallCount += 1
        deletionCompletion.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletion[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletion[index](nil)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date) {
        insertCallCount += 1
        insertions.append((items, timestamp))
    }
}

class CachedFeedUseCaseTests: XCTestCase {
    
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
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let error = anyNSError()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items)
        store.completeDeletion(with: error)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestNewCacheInsertionOnSuccessfullDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
            let timestamp = Date()
            let items = [uniqueItem(), uniqueItem()]
            let (sut, store) = makeSUT(currentDate: { timestamp })

            sut.save(items: items)
            store.completeDeletionSuccessfully()

            XCTAssertEqual(store.insertions.count, 1)
            XCTAssertEqual(store.insertions.first?.items, items)
            XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
        }
    
    // MARK: Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
