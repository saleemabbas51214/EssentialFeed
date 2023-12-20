//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by abbas on 09.12.23.
//


/// we did not conform to the feedloader protocol , so the answer is we can take smaller and safer steps by test driving the implementation we dont need it yet when the time comes then we will do the conformance
/// we prevent subclassing remotefeedloader so set it final

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}

public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    public func load() {
        client.get(from: url)
    }
}


