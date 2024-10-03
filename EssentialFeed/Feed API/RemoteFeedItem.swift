//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by abbas on 03.10.24.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
