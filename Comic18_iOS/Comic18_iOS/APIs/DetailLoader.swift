//
//  DetailLoader.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/4/23.
//

import Foundation

public class DetailLoader {
    private let comicID: String
    private let crawler: DetailCrawler
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(comicID: String) {
        self.comicID = comicID
        crawler = DetailCrawler(comicID: comicID)
    }
    
    public func getDetail(completion: @escaping (Result<ComicDetail, Error>) -> Void) {
        crawler.getDetailJSON { result in
            switch result {
            case let .success(json):
                let detailItem = ComicDetail(json: json)
                completion(.success(detailItem))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
