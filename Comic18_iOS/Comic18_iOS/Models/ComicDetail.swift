//
//  ComicDetail.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/4/23.
//

import Foundation

public struct ComicDetail: Equatable {
    let id: String
    let title: String
    let coverImage: String
    let previewImages: [String]
    let authors: [String]
    let tags: [String]
    let description: String
    let pages: Int
    let releaseDate: String
    let updateDate: String
    let watchCount: Int
    let likeCount: String
    let chapters: [Chapter]
    
    public init(json: [String: Any]) {
        id = json["id"] as? String ?? ""
        title = json["title"] as? String ?? ""
        coverImage = json["cover_image"] as? String ?? ""
        previewImages = json["preview_images"] as? [String] ?? []
        authors = json["authors"] as? [String] ?? []
        tags = json["tags"] as? [String] ?? []
        description = json["description"] as? String ?? ""
        pages = json["pages"] as? Int ?? 0
        releaseDate = json["release_date"] as? String ?? ""
        updateDate = json["update_date"] as? String ?? ""
        watchCount = json["watch_count"] as? Int ?? 0
        likeCount = json["like_count"] as? String ?? ""
        chapters = (json["chapters"] as? [[String: Any]] ?? []).map { Chapter(json: $0) }
    }
    
    public static func == (lhs: ComicDetail, rhs: ComicDetail) -> Bool {
        return (lhs.id == rhs.id &&
                lhs.title == rhs.title &&
                lhs.previewImages == rhs.previewImages &&
                lhs.authors == rhs.authors &&
                lhs.tags == rhs.tags &&
                lhs.description == rhs.description &&
                lhs.pages == rhs.pages &&
                lhs.releaseDate == rhs.releaseDate &&
                lhs.updateDate == rhs.updateDate &&
                lhs.watchCount == rhs.watchCount &&
                lhs.likeCount == rhs.likeCount &&
                lhs.chapters == rhs.chapters)
    }
}

public struct Chapter: Equatable, Decodable {
    let id: String
    let number: Int
    let title: String
    let releaseDate: String
    
    public init(json: [String: Any]) {
        id = json["id"] as? String ?? ""
        number = json["number"] as? Int ?? 0
        title = json["title"] as? String ?? ""
        releaseDate = json["release_date"] as? String ?? ""
    }
    
    public static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        return (lhs.id == rhs.id &&
                lhs.number == rhs.number &&
                lhs.title == rhs.title &&
                lhs.releaseDate == rhs.releaseDate)
    }
}
