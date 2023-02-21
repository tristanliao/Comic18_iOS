//
//  Comic.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/2/21.
//

import Foundation

public struct Comic: Equatable {
    let id: String
    let title: String
    let authors: [String]
    let imageURL: URL?
    let tags: [String]
    let likesCount: String
    let category: String
    let subCategory: String?
    
    public init(
        id: String,
        title: String,
        authors: [String],
        imageURL: URL? = nil,
        tags: [String],
        likesCount: String,
        category: String,
        subCategory: String? = nil
    ) {
        self.id = id
        self.title = title
        self.authors = authors
        self.imageURL = imageURL
        self.tags = tags
        self.likesCount = likesCount
        self.category = category
        self.subCategory = subCategory
    }
}

extension Comic {
    public init(json: [String: Any]) {
        id = json["id"] as? String ?? ""
        title = json["title"] as? String ?? ""
        authors = json["authors"] as? [String] ?? []
        imageURL = URL(string: json["image"] as? String ?? "")
        tags = json["tags"] as? [String] ?? []
        likesCount = json["likesCount"] as? String ?? ""
        category = json["category"] as? String ?? ""
        subCategory = json["subCategory"] as? String
    }
}
