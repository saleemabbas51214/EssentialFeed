//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by abbas on 09.12.23.
//


/// we did not conform to the feedloader protocol , so the answer is we can take smaller and safer steps by test driving the implementation we dont need it yet when the time comes then we will do the conformance

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}

protocol HTTPClient {
    func get(from url: URL)
}

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    func load() {
        client.get(from: url)
    }
}


