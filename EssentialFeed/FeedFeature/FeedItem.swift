//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by abbas on 09.12.23.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: String?
}
