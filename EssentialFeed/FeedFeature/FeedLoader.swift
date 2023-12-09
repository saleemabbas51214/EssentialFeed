//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by abbas on 09.12.23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
