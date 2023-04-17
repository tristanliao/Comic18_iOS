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
        getDetailHTML { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(html):
                completion(.success(self.parse(html: html)))
            case let.failure(error):
                completion(.failure(.connectivity))
            }
        }
    }
    
    // MARK: - Parsers
    
    private func parse(html: String) -> [String: Any] {
        guard let document = try? SwiftSoup.parse(html) else {
            return [:]
        }
        
        var json: [String: Any] = [
            "id": comicID,
            "title" : parseTitle(from: document),
            "coverImage": parseCoverImage(),
            "preview_images": parsePreviewImages(from: document),
            "authors": parseAuthors(from: document),
            "tags": parseTags(from: document),
            "description": parseDescription(from: document),
            "pages": parsePageNumber(from: document),
            "release_date": parseReleaseDate(from: document),
            "update_date": parseUpdateDate(from: document),
            "watch_count": parseWatchCount(from: document),
            "like_count": parseLikeCount(from: document)
        ]
        
        if let chapters = parseChapters(from: document) {
            json["chapters"] = chapters
        }
        
        return json
    }
}

// MARK: - Parser

extension DetailCrawler {
    private func parseTitle(from document: Document) -> String {
        guard let title = try? document.getElementsByTag("title").first?.text() else {
            print("Parse error: Can't find title element in the HTML.")
            return ""
        }
        
        return title
    }
    
    private func parseCoverImage() -> String {
        return "https://18comic.vip/media/albums/\(comicID).jpg"
    }
    
    private func parsePreviewImages(from document: Document) -> [String] {
        guard let previewElements = try? document.getElementsByClass("img_zoom_img") else {
            print("Parse error: Can't find preview image elements in the HTML.")
            return []
        }
        
        return previewElements.compactMap { try? $0.select("img").first?.attr("data-original") }
    }
    
    private func parseAuthors(from document: Document) -> [String] {
        guard let authorElement = findElement(from: document, with: "作者：") else {
            print("Parse error: Can't find author element in the HTML.")
            return []
        }
        
        let authors = try? authorElement.select("a").compactMap {
            do {
                let text = try $0.text()
                return text
            } catch {
                return nil
            }
        }
        
        return authors ?? []
    }
    
    private func parseTags(from document: Document) -> [String] {
        guard let tagElement = findElement(from: document, with: "標籤：") else {
            print("Parse error: Can't find tag element in the HTML.")
            return []
        }
        
        let tags = try? tagElement.select("a").compactMap {
            do {
                let text = try $0.text()
                return text
            } catch {
                return nil
            }
        }
        
        return tags ?? []
    }
    
    private func parseDescription(from document: Document) -> String {
        guard let element = findElement(from: document, with: "敘述：") else {
            print("Parse error: Can't find description element in the HTML.")
            return ""
        }
        
        return (try? element.text()) ?? ""
    }
    
    private func parsePageNumber(from document: Document) -> Int {
        guard let element = findElement(from: document, with: "頁數："), let pageString = try? element.text() else {
            print("Parse error: Can't find page element in the HTML.")
            return 0
        }
        
        return Int(pageString.replacingOccurrences(of: "頁數：", with: "")) ?? 0
    }
    
    private func parseReleaseDate(from document: Document) -> String {
        guard let element = findElement(from: document, with: "上架日期") else {
            print("Parse error: Can't find release date element in the HTML.")
            return ""
        }
        
        guard let spans = try? element.select("span"), let releaseDateString = try? spans.first?.text() else {
            return ""
        }
        
        return releaseDateString.replacingOccurrences(of: "上架日期 : ", with: "")
    }
    
    private func parseUpdateDate(from document: Document) -> String {
        guard let element = findElement(from: document, with: "更新日期") else {
            print("Parse error: Can't find update date element in the HTML.")
            return ""
        }
        
        guard let spans = try? element.select("span"), spans.count > 1, let updateDateString = try? spans[1].text() else {
            return ""
        }
        
        return updateDateString.replacingOccurrences(of: "更新日期 : ", with: "")
    }
    
    private func parseWatchCount(from document: Document) -> Int {
        guard let element = findElement(from: document, with: "次觀看") else {
            print("Parse error: Can't find watch count element in the HTML.")
            return 0
        }
        
        guard let spans = try? element.select("span"), spans.count > 4, let watchCountString = try? spans[4].text() else {
            return 0
        }
        
        return Int(watchCountString) ?? 0
    }
    
    private func parseLikeCount(from document: Document) -> String {
        guard let element = findElement(from: document, with: "點擊喜歡") else {
            print("Parse error: Can't find like count element in the HTML.")
            return ""
        }
        
        guard let spans = try? element.select("span"), spans.count > 6, let likeCountString = try? spans[6].text() else {
            return ""
        }
        
        return likeCountString
    }
    
    private func parseChapters(from document: Document) -> [[String: Any]]? {
        guard let element = try? document.getElementsByClass("episode").first else {
            print("Parse error: Can't find chapters element in the HTML.")
            return nil
        }
        
        let chapters = try? element.select("a").map { element in
            let id = try? element.attr("data-album")
            let text = try? element.select("li").first?.text()
            var number = 0
            var title = ""
            var date = ""
            
            if let text = text {
                let components = text.components(separatedBy: .whitespaces)
                date = components.last ?? ""
                let numberString = components.first?.replacingOccurrences(of: "第", with: "").replacingOccurrences(of: "話", with: "") ?? ""
                number = Int(numberString) ?? 0
                
                if components.count > 2, components[components.count - 2] == "最新" {
                    let titleArray = Array(components[1..<components.count-2])
                    title = titleArray.joined(separator: " ")
                } else {
                    let titleArray = Array(components[1...components.count-2])
                    title = titleArray.joined(separator: " ")
                }
            }
            
            return [
                "id": id as Any,
                "number": number,
                "title": title,
                "date": date
            ]
        }
        
        return chapters
    }
    
    private func findElement(from document: Document, with keyword: String) -> Element? {
        var element: Element?
        
        if let tagBlockElements = try? document.getElementsByClass("tag-block") {
            element = tagBlockElements.first {
                do {
                    let text = try $0.text()
                    return text.contains(keyword)
                } catch {
                    return false
                }
            }
        }
        
        if element != nil { return element }
        
        if let otherBlockElement = try? document.getElementsByClass("p-t-5 p-b-5") {
            element = otherBlockElement.first {
                do {
                    let text = try $0.text()
                    return text.contains(keyword)
                } catch {
                    return false
                }
            }
        }
        
        return element
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
        
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers
    
    private func makeSUT() -> DetailCrawler {
        return DetailCrawler(comicID: "208122")
    }
    
    private var anyNSError: NSError {
        NSError(domain: "any error", code: 0)
    }
    
    private func makeDetailItemJSON() -> [String: Any] {
        [
            "id": 208122,
            "title": "難得拿到外掛轉生至異世界，就想要隨心所欲過生活 [ブッチャーU×ムンムン×水龍敬] せっかくチートを貰って異世界に転移したんだから、好きなように生きてみたい",
            "preview_images": [
                "https://cdn-msp.18comic.vip/media/albums/208122.jpg?v=1678600760",
                "https://cdn-msp.18comic.vip/media/photos/208122/00018.webp",
                "https://cdn-msp.18comic.vip/media/photos/208122/00157.webp",
                "https://cdn-msp.18comic.vip/media/photos/208122/00039.webp"
            ],
            "authors": [
                "ブッチャーU",
                "ムンムン",
                "水龍敬"
            ],
            "tags": [
                "巨乳",
                "妖精",
                "獸耳",
                "劇情向",
                "群交",
                "中文",
                "青年漫",
                "异世界",
                "ngực",
                "to"
            ],
            "description": """
                敘述：佐藤太郎是個三十多歲的上班族，職業是建築工地的監工。有一天他因為一場意外而不幸喪命，但是某個疑似是神的存在，賦予他治癒魔法與製作回復藥的外掛能力，並讓他轉生到異世界。
            我必須戰鬥──跟那些傢伙戰鬥！
            太郎運用那有如外掛般的卓越能力，不再缺錢花用、生活變得充裕，於是他改名為塔武洛，前往異世界的紅燈區享受花天酒地的生活。於是，在異世界流傳的新傳說就此開幕──或許吧……
            """,
            "pages": 1027,
            "release_date": "2020-08-03",
            "update_date": "2023-02-26",
            "watch_count": 10586686,
            "like_count": "65.8K",
            "chapters": [
                [
                    "id": 208319,
                    "number": 1,
                    "title": "難得拿到外掛轉生至異世界，就想要隨心所欲過生活 [ブッチャーU×ムンムン×水龍敬] せっかくチートを貰って異世界に転移したんだから、好きなように生きてみたい",
                    "release_date": "2020-08-03"
                ]
            ]
        ]
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

