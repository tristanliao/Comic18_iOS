//
//  HomeLoaderTests.swift
//  Comic18_iOSTests
//
//  Created by Bang Chiang Liao on 2023/2/18.
//

import XCTest
import Comic18_iOS

final class HomeLoaderTests: XCTestCase {

    override func setUpWithError() throws {
        URLProtocolStub.startInterceptingRequest()
    }

    override func tearDownWithError() throws {
        URLProtocolStub.stopInterceptionRequest()
    }

    func test_loadRecentComics_deliversItemsOn200HTTPResponseWithJSONItems() {
        let sut = makeSUT()
        let json = loadJSON(fileName: "recent_comics")
        let expectedComics = generateComicItems(from: json)
        
        let exp = expectation(description: "Wait for loading recent comics")
        
        sut.loadRecentComics { result in
            switch result {
            case let .success(receivedComics):
                XCTAssertEqual(expectedComics, receivedComics)
            default:
                XCTFail("Transfer recent comic from json to Comics object failed.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_loadLatestKoreanComics_deliversItemsOn200HTTPResponseWithJSONItems() {
        let sut = makeSUT()
        let json = loadJSON(fileName: "latest_korean_comics")
        let expectedComics = generateComicItems(from: json)
        
        let exp = expectation(description: "Wait for loading latest korean comics")
        
        sut.loadLatestKoreanComics { result in
            switch result {
            case let .success(receivedComics):
                XCTAssertEqual(expectedComics, receivedComics)
            default:
                XCTFail("Transfer recent comic from json to Comics object failed.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_loadRecommendComics_deliversItemsOn200HTTPResponseWithJSONItems() {
        let sut = makeSUT()
        let json = loadJSON(fileName: "recommend_comics")
        let expectedComics = generateComicItems(from: json)
        
        let exp = expectation(description: "Wait for loading recommend comics")
        
        sut.loadRecommendComics { result in
            switch result {
            case let .success(receivedComics):
                XCTAssertEqual(expectedComics, receivedComics)
            default:
                XCTFail("Transfer recent comic from json to Comics object failed.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_loadLatestComics_deliversItemsOn200HTTPResponseWithJSONItems() {
        let sut = makeSUT()
        let json = loadJSON(fileName: "latest_comics")
        let expectedComics = generateComicItems(from: json)
        
        let exp = expectation(description: "Wait for loading recommend comics")
        
        sut.loadLatestComics { result in
            switch result {
            case let .success(receivedComics):
                XCTAssertEqual(expectedComics, receivedComics)
            default:
                XCTFail("Transfer recent comic from json to Comics object failed.")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }

    // MARK: - Helpers
    
    private func makeSUT() -> HomeLoader {
        let sut = HomeLoader()
        let htmlData = loadHTML(fileName: "comic18_home")
        URLProtocolStub.stub(data: htmlData, response: anyURLResponse, error: nil)
        
        return sut
    }
    
    private func generateComicItems(from json: [[String: Any]]) -> [Comic] {
        json.map {
            Comic(
                id: $0["id"] as! String,
                title: $0["title"] as! String,
                authors: $0["authors"] as! [String],
                imageURL: URL(string: $0["image"] as! String)!,
                tags: $0["tags"] as! [String],
                likesCount: $0["likesCount"] as! String,
                category: $0["category"] as! String,
                subCategory: $0["subCategory"] as? String
            )
        }
    }
}
