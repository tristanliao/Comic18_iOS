//
//  DetailLoaderTests.swift
//  Comic18_iOSTests
//
//  Created by Bang Chiang Liao on 2023/4/21.
//

import XCTest
import Comic18_iOS

class DetailLoader {
    private let comicID: String
    private let crawler: DetailCrawler
    
    enum Error: Swift.Error {
        case connectivity
    }
    
    init(comicID: String) {
        self.comicID = comicID
        crawler = DetailCrawler(comicID: comicID)
    }
    
    func getDetail(completion: @escaping (Result<ComicDetail, Error>) -> Void) {
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

struct ComicDetail: Equatable {
    let id: String
    let title: String
    let coverImage: String
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
        coverImage = json["cover_image"] as? String ?? ""
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
    
    static func == (lhs: ComicDetail, rhs: ComicDetail) -> Bool {
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

struct Chapter: Equatable, Decodable {
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
    
    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        return (lhs.id == rhs.id &&
                lhs.number == rhs.number &&
                lhs.title == rhs.title &&
                lhs.releaseDate == rhs.releaseDate)
    }
}

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
