//
//  DetailCrawlerTests.swift
//  Comic18_iOSTests
//
//  Created by Bang Chiang Liao on 2023/2/26.
//

import XCTest
import SwiftSoup

class DetailCrawler {
    private enum Constants {
        static let detailURL = "https://18comic.vip/album"
    }
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let session: URLSession
    let comicID: String
    var detailHTML: String?
    
    init(comicID: String, session: URLSession = .shared) {
        self.comicID = comicID
        self.session = session
    }
    
    private func getDetailHTML(completion: @escaping (Result<String, Error>) -> Void) {
        if let detailHTML {
            completion(.success(detailHTML))
            return
        }
        
        session.dataTask(with: URL(string: Constants.detailURL)!) { data, response, error in
            if error != nil {
                completion(.failure(.connectivity))
            } else if let data = data, let html = String(data: data, encoding: .utf8) {
                completion(.success(html))
            } else {
                completion(.failure(.invalidData))
            }
        }.resume()
    }
    
    func getDetailJSON(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        getDetailHTML { result in
            switch result {
            case let .success(html):
                completion(.success([:]))
            case let.failure(error):
                completion(.failure(.connectivity))
            }
        }
    }
}

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

    // MARK: - Helpers
    
    private func makeSUT() -> DetailCrawler {
        return DetailCrawler(comicID: "208122")
    }
    
    private var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }
    
}
