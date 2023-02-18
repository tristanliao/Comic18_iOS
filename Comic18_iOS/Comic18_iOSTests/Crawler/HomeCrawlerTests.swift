//
//  HomeCrawlerTests.swift
//  Comic18_iOSTests
//
//  Created by Bang Chiang Liao on 2023/2/15.
//

import XCTest
import Comic18_iOS

final class HomeCrawlerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }

    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptionRequest()
    }
    
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
    
    func test_getRecommendComics_deliverItemsOnSuccess() {
        let sut = makeSUT()
        let expectedComicsJSON = loadJSON(fileName: "recommend_comics")
        
        let exp = expectation(description: "Wait for recommend comics")
        
        sut.getRecommendComics() { result in
            switch result {
            case let .success(receivedComicsJSON):
                XCTAssertEqual(receivedComicsJSON.count, 20)
                self.XCTAssertEqualComicsJSON(expectedComicsJSON, receivedComicsJSON)
            default:
                XCTFail("Get recommend comics failed")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_getLatestComics_deliverItemsOnSuccess() {
        let sut = makeSUT()
        let expectedComicsJSON = loadJSON(fileName: "latest_comics")
        
        let exp = expectation(description: "Wait for latest comics")
        
        sut.getLatestComics() { result in
            switch result {
            case let .success(receivedComicsJSON):
                XCTAssertEqual(receivedComicsJSON.count, 60)
                self.XCTAssertEqualComicsJSON(expectedComicsJSON, receivedComicsJSON)
            default:
                XCTFail("Get latest comics failed")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> HomeCrawler {
        let sut = HomeCrawler()
        let htmlData = loadHTML()
        URLProtocolStub.stub(data: htmlData, response: anyURLResponse, error: nil)
        
        trackMemoryLeak(sut)
        
        return sut
    }
    
    private func loadHTML() -> Data? {
        guard let path = Bundle(for: type(of: self)).path(forResource: "comic18_home", ofType: "html") else { return nil }
        guard let data = try? Data(contentsOf: URL(filePath: path)) else { return nil }
        
        return data
    }
    
    private var anyURLResponse: URLResponse {
        URLResponse()
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
