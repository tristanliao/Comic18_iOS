//
//  HomeCrawler.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/2/17.
//

import Foundation
import SwiftSoup

public class HomeCrawler {
    private enum Constants {
        static let homeURL = "https://18comic.vip"
    }
    
    private let session: URLSession
    private var homeHTML: String?
    
    public enum Error: Swift.Error {
        case connectivity
        case unexpectedValueRepresentation
    }
    
    public init(session: URLSession = .shared, html: String? = nil) {
        self.session = session
        self.homeHTML = html
    }
    
    private func getHomeHTML(completion: @escaping (Result<String, Error>) -> Void) {
        if let homeHTML {
            completion(.success(homeHTML))
            return
        }
        
        session.dataTask(with: URL(string: Constants.homeURL)!) { data, response, error in
            if error != nil {
                completion(.failure(.connectivity))
            } else if let data = data, let html = String(data: data, encoding: .utf8) {
                completion(.success(html))
            } else {
                completion(.failure(.unexpectedValueRepresentation))
            }
        }.resume()
    }
    
    private func parseRecentComics(from html: String) -> [[String: Any]] {
        guard let body = try? SwiftSoup.parseBodyFragment(html) else {
            return []
        }
        
        guard let comicsCategories = try? body.getElementsByClass("row m-b-10"), !comicsCategories.isEmpty else {
            return []
        }
        
        guard let recentCategory = try? comicsCategories[0].getElementsByClass("p-b-15") else {
            return []
        }
        
        let comicsJSON = recentCategory.map { element in
            return generateComicJSON(from: element)
        }
        
        return comicsJSON
    }
    
    private func parseLatestKoreanComics(from html: String) -> [[String: Any]] {
        guard let body = try? SwiftSoup.parseBodyFragment(html) else {
            return []
        }
        
        guard let comicsCategories = try? body.getElementsByClass("row m-b-10"), !comicsCategories.isEmpty else {
            return []
        }
        
        guard let recentCategory = try? comicsCategories[1].getElementsByClass("p-b-15") else {
            return []
        }
        
        let comicsJSON = recentCategory.map { element in
            return generateComicJSON(from: element)
        }
        
        return comicsJSON
    }
    
    private func parseRecommendComics(from html: String) -> [[String: Any]] {
        guard let body = try? SwiftSoup.parseBodyFragment(html) else {
            return []
        }
        
        guard let comicsCategories = try? body.getElementsByClass("row m-b-10"), !comicsCategories.isEmpty else {
            return []
        }
        
        guard let recentCategory = try? comicsCategories[5].getElementsByClass("p-b-15") else {
            return []
        }
        
        let comicsJSON = recentCategory.map { element in
            return generateComicJSON(from: element)
        }
        
        return comicsJSON
    }
    
    private func parseLatestComics(from html: String) -> [[String: Any]] {
        guard let body = try? SwiftSoup.parseBodyFragment(html) else {
            return []
        }
        
        guard let comicsCategories = try? body.getElementsByClass("row m-0"), !comicsCategories.isEmpty else {
            return []
        }
        
        guard let recentCategory = try? comicsCategories[0].getElementsByClass("p-b-15") else {
            return []
        }
        
        let comicsJSON = recentCategory.map { element in
            return generateComicJSON(from: element)
        }
        
        return comicsJSON
    }
    
    private func generateComicJSON(from element: Element) -> [String: Any] {
        var json = [String: Any]()
        json["id"] = try? element.select("a").first()?.attr("href").components(separatedBy: "/")[2]
        json["title"] = try? element.getElementsByClass("video-title").first()?.text()
        json["authors"] = try? element.getElementsByClass("hidden-xs").first()?.select("a").compactMap { try $0.text() }
        json["category"] = try? element.getElementsByClass("label-category").first()?.text()
        json["subCategory"] = try? element.getElementsByClass("label-sub").first()?.text()
        json["tags"] = try? element.getElementsByClass("tag").compactMap { try $0.text() }
        json["image"] = try? element.select("img").first()?.attr("data-src")
        json["likesCount"] = try? element.getElementById("albim_likes_\(json["id"] ?? "")")?.text()
        return json
    }
    
    public func getRecentComics(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        getHomeHTML { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(html):
                let recentComicsJSON = self.parseRecentComics(from: html)
                completion(.success(recentComicsJSON))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public func getLatestKoreanComics(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        getHomeHTML { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(html):
                let recentComicsJSON = self.parseLatestKoreanComics(from: html)
                completion(.success(recentComicsJSON))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public func getRecommendComics(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        getHomeHTML { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(html):
                let recentComicsJSON = self.parseRecommendComics(from: html)
                completion(.success(recentComicsJSON))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public func getLatestComics(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        getHomeHTML { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(html):
                let latestComicsJSON = self.parseLatestComics(from: html)
                completion(.success(latestComicsJSON))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
