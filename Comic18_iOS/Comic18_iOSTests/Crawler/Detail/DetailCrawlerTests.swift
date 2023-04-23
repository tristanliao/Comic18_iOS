//
//  DetailCrawlerTests.swift
//  Comic18_iOSTests
//
//  Created by Bang Chiang Liao on 2023/2/26.
//

import XCTest
import Comic18_iOS

final class DetailCrawlerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptionRequest()
    }

    func test_loadComicDetail_deliversError() {
        let sut = makeSUT()
        URLProtocolStub.stub(data: nil, response: nil, error: anyNSError)
        
        let exp = expectation(description: "Wait for getting detail json")
        
        sut.getDetailJSON { result in
            switch result {
            case let .failure(error):
                XCTAssertEqual(error, .connectivity)
            default:
                XCTFail("Expect connectivity error, but get result")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_loadComicDetail_deliversItemSuccessfully() {
        let sut = makeSUT()
        let html = loadHTML(fileName: "comic18_detail_208122")
        URLProtocolStub.stub(data: html, response: anyURLResponse, error: nil)
        let expectedDetailJSON = loadJSON(fileName: "comic18_detail_208122")
        
        let exp = expectation(description: "Wait for completion")
        
        sut.getDetailJSON { result in
            switch result {
            case let .success(receivedDetailJSON):
                let expectedDetailItem = DetailItem(json: expectedDetailJSON)
                let receivedDetailItem = DetailItem(json: receivedDetailJSON)
                XCTAssertEqual(expectedDetailItem, receivedDetailItem)
            default:
                XCTFail("Expect to get detail JSON, got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> DetailCrawler {
        let crawler = DetailCrawler(comicID: "208122")
        
        trackMemoryLeak(crawler, file: file, line: line)
        
        return crawler
    }
    
    private var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private class DetailItem: Equatable {
        let id: String
        let title: String
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
        
        init(json: [String: Any]) {
            id = json["id"] as? String ?? ""
            title = json["title"] as? String ?? ""
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
        
        static func == (lhs: DetailCrawlerTests.DetailItem, rhs: DetailCrawlerTests.DetailItem) -> Bool {
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
    
    private class Chapter: Equatable, Decodable {
        let id: String
        let number: Int
        let title: String
        let releaseDate: String
        
        init(json: [String: Any]) {
            id = json["id"] as? String ?? ""
            number = json["number"] as? Int ?? 0
            title = json["title"] as? String ?? ""
            releaseDate = json["release_date"] as? String ?? ""
        }
        
        static func == (lhs: DetailCrawlerTests.Chapter, rhs: DetailCrawlerTests.Chapter) -> Bool {
            return (lhs.id == rhs.id &&
                    lhs.number == rhs.number &&
                    lhs.title == rhs.title &&
                    lhs.releaseDate == rhs.releaseDate)
        }
    }
    
}

