//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by abbas on 03.10.24.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCachedItems(completion: @escaping DeletionCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
