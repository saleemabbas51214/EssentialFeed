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
    
    enum ReceivedMessage: Equatable {
            case deleteCachedFeed
            case insert([FeedItem], Date)
        }

    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletion = [DeletionCompletion]()

    func deleteCachedItems(completion: @escaping DeletionCompletion) {
        deletionCompletion.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletion[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletion[index](nil)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date) {
        receivedMessages.append(.insert(items, timestamp))
    }
}

class CachedFeedUseCaseTests: XCTestCase {
    
    func test_doNot_Delete_CachedItem_On_Creation() {
        let (_ , store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()

        let items = [uniqueItem(), uniqueItem()]
        sut.save(items: items)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let error = anyNSError()
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items: items)
        store.completeDeletion(with: error)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
            let timestamp = Date()
            let items = [uniqueItem(), uniqueItem()]
            let (sut, store) = makeSUT(currentDate: { timestamp })

            sut.save(items: items)
            store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
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
