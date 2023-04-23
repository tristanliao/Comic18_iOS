//
//  DetailLoaderTests.swift
//  Comic18_iOSTests
//
//  Created by Bang Chiang Liao on 2023/4/21.
//

import XCTest
import Comic18_iOS

final class DetailLoaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptionRequest()
    }
    
    func test_loadDetail_deliversItemOn200HTTPResponseWithJSONItem() {
        let sut = makeSUT()
        let json = loadJSON(fileName: "comic18_detail_208122")
        let expectedItem = ComicDetail(json: json)
        
        let exp = expectation(description: "Wait for response")
        
        sut.getDetail { result in
            switch result {
            case let .success(receivedItem):
                XCTAssertEqual(expectedItem, receivedItem)
            default:
                XCTFail("Expect get detail successfully, got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_loadDetail_deliversErrorOnNon200HTTPResponse() {
        let sut = makeSUT()
        URLProtocolStub.stub(data: nil, response: nil, error: anyNSError)
        
        let exp = expectation(description: "Wait for response")
        
        sut.getDetail { result in
            switch result {
            case let .failure(receivedError):
                XCTAssertEqual(receivedError, .connectivity)
            default:
                XCTFail("Expect get detail with network error, got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
    }

    // MARK: - Helper methods
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> DetailLoader {
        let sut = DetailLoader(comicID: "208122")
        let htmlData = loadHTML(fileName: "comic18_detail_208122")
        URLProtocolStub.stub(data: htmlData, response: anyURLResponse, error: nil)
        
        trackMemoryLeak(sut)
        
        return sut
    }
    
    private var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }

}
