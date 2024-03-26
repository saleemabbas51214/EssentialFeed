//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by abbas on 09.12.23.
//


/// we did not conform to the feedloader protocol , so the answer is we can take smaller and safer steps by test driving the implementation we dont need it yet when the time comes then we will do the conformance
/// we prevent subclassing remotefeedloader so set it final

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadFeedResult) -> Void)
}




