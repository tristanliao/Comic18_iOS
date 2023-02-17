//
//  HomeCrawlerTests.swift
//  Comic18_iOSTests
//
//  Created by Bang Chiang Liao on 2023/2/15.
//

import XCTest
import SwiftSoup

class HomeCrawler {
    private enum Constants {
        static let homeURL = "https://18comic.vip"
    }
    
    private let session: URLSession
    private var homeHTML: String?
    
    enum Error: Swift.Error {
        case connectivity
        case unexpectedValueRepresentation
    }
    
    init(session: URLSession = .shared, html: String? = nil) {
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
    
    func getRecentComics(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
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
    
    func getLatestKoreanComics(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
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
}

final class HomeCrawlerTests: XCTestCase {

    func test_getRecentComics_success() throws {
        let sut = makeSUT()
        let expectedComicsJSON = loadJSON(fileName: "recent_comics")
        
        let exp = expectation(description: "Wait for recent comics")
        
        sut.getRecentComics { result in
            switch result {
            case let .success(receivedComicsJSON):
                XCTAssertEqual(receivedComicsJSON.count, 20)
                self.XCTAssertEqualComicsJSON(expectedComicsJSON, receivedComicsJSON)
            default:
                XCTFail("Get wrong recent comics")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_getLatestKoreanComics_deliverItemsOnSuccess() {
        let sut = makeSUT()
        let expectedComicsJSON = loadJSON(fileName: "latest_korean_comics")
        
        let exp = expectation(description: "Wait for latest korean comics")
        
        sut.getLatestKoreanComics() { result in
            switch result {
            case let .success(receivedComicsJSON):
                XCTAssertEqual(receivedComicsJSON.count, 20)
                self.XCTAssertEqualComicsJSON(expectedComicsJSON, receivedComicsJSON)
            default:
                XCTFail("Get latest korean comics failed")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> HomeCrawler {
        let html = loadHTML()
        return HomeCrawler(html: html)
    }
    
    private func loadHTML() -> String {
        guard let path = Bundle(for: type(of: self)).path(forResource: "comic18_home", ofType: "html") else { return "" }
        guard let data = try? Data(contentsOf: URL(filePath: path)) else { return "" }
        
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    private func XCTAssertEqualComicsJSON(_ first: [[String: Any]], _ second: [[String: Any]], file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(first.count, second.count, file: file, line: line)
        
        for (firstJSON, secondJSON) in zip(first, second) {
            XCTAssertEqual(firstJSON["id"] as? String, secondJSON["id"] as? String, file: file, line: line)
            XCTAssertEqual(firstJSON["title"] as? String, secondJSON["title"] as? String, file: file, line: line)
            XCTAssertEqual(firstJSON["image"] as? String, secondJSON["image"] as? String, file: file, line: line)
            XCTAssertEqual(firstJSON["authors"] as? [String], secondJSON["authors"] as? [String], file: file, line: line)
            XCTAssertEqual(firstJSON["tags"] as? [String], secondJSON["tags"] as? [String], file: file, line: line)
            XCTAssertEqual(firstJSON["category"] as? String, secondJSON["category"] as? String, file: file, line: line)
            XCTAssertEqual(firstJSON["subCategory"] as? String, secondJSON["subCategory"] as? String, file: file, line: line)
            XCTAssertEqual(firstJSON["likesCount"] as? String, secondJSON["likesCount"] as? String, file: file, line: line)
        }
    }
    
    private func loadJSON(fileName: String, file: StaticString = #filePath, line: UInt = #line) -> [[String: Any]] {
        guard let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json") else { return [] }
        guard let data = try? Data(contentsOf: URL(filePath: path)) else { return [] }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            XCTFail("Load json file fail", file: file, line: line)
            return []
        }
        
        return json
    }
}
