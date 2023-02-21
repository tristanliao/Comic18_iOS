//
//  HomeLoader.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/2/18.
//

import Foundation

public final class HomeLoader {
    private let crawler = HomeCrawler()
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init() {}
    
    public func loadRecentComics(completion: @escaping (Result<[Comic], Error>) -> Void) {
        crawler.getRecentComics { result in
            switch result {
            case let .success(comicsJSON):
                let comics = comicsJSON.map { Comic(json: $0) }
                completion(.success(comics))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    public func loadLatestKoreanComics(completion: @escaping (Result<[Comic], Error>) -> Void) {
        crawler.getLatestKoreanComics { result in
            switch result {
            case let .success(comicsJSON):
                let comics = comicsJSON.map { Comic(json: $0) }
                completion(.success(comics))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    public func loadRecommendComics(completion: @escaping (Result<[Comic], Error>) -> Void) {
        crawler.getRecommendComics { result in
            switch result {
            case let .success(comicsJSON):
                let comics = comicsJSON.map { Comic(json: $0) }
                completion(.success(comics))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    public func loadLatestComics(completion: @escaping (Result<[Comic], Error>) -> Void) {
        crawler.getLatestComics { result in
            switch result {
            case let .success(comicsJSON):
                let comics = comicsJSON.map { Comic(json: $0) }
                completion(.success(comics))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
