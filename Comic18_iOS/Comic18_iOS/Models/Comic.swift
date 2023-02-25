//
//  Comic.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/2/21.
//

import Foundation

public struct Comic: Equatable, Identifiable, Hashable {
    public let id: String
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

extension Comic {
    static var mockComic1: Comic {
        Comic(
            id: "239421",
            title: "灰姑娘的哥哥們 Brothers of Cinderella [零星漢化組x禁漫天堂]",
            authors: [
                "HanNyang",
                "L.Y."
            ],
            imageURL: URL(string: "https://cdn-msp.18comic.org/media/albums/239421_3x4.jpg?v=1675312840")!,
            tags: [
                "女性向",
                "韓漫",
                "連載中"
            ],
            likesCount: "4K",
            category: "單本",
            subCategory: "漢化"
        )
    }
    
    static var mockComic2: Comic {
        Comic(
            id: "263004",
            title: "從指尖開始的熱情 ～青梅竹馬是消防員～[川野タニシ] 指先から本気の熱情～チャラ男消防士はまっすぐな目で私を抱いた～[最愛福瑞漢化組*禁漫天堂]",
            authors: [
                "川野タニシ"
            ],
            imageURL: URL(string: "https://cdn-msp.18comic.org/media/albums/263004_3x4.jpg?v=1675312840")!,
            tags: [
                "劇情向",
                "動畫化",
                "女性向",
                "中文"
            ],
            likesCount: "26.4K",
            category: "單本",
            subCategory: "漢化"
        )
    }
    
    static var mockComic3: Comic {
        Comic(
            id: "278762",
            title: "討厭的女人/讨厌的女人 [박미남/조상덕] [不咕鳥漢化組X禁漫天堂]",
            authors: [
                "박미남",
                "조상덕",
                "朴美男"
            ],
            imageURL: URL(string: "https://cdn-msp.18comic.org/media/albums/278762_3x4.jpg?v=1675312840")!,
            tags: [
                "全彩",
                "百合",
                "劇情向",
                "完結",
                "中文"
            ],
            likesCount: "28.6K",
            category: "單本"
        )
    }
}
