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
        let expectedComicsJSON = loadJSONArray(fileName: "recent_comics")
        
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
        let expectedComicsJSON = loadJSONArray(fileName: "latest_korean_comics")
        
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
        let expectedComicsJSON = loadJSONArray(fileName: "recommend_comics")
        
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
        let expectedComicsJSON = loadJSONArray(fileName: "latest_comics")
        
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
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HomeCrawler {
        let sut = HomeCrawler()
        let htmlData = loadHTML(fileName: "comic18_home")
        URLProtocolStub.stub(data: htmlData, response: anyURLResponse, error: nil)
        
        trackMemoryLeak(sut, file: file, line: line)
        
        return sut
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
}
