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
        
        return comicsJSON
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
}

final class HomeCrawlerTests: XCTestCase {

    func test_getRecentComics_success() throws {
        let sut = makeSUT()
        let expectedComicsJSON = mockRecentComics
        
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
    
    // MARK: - Helpers
    
    func makeSUT() -> HomeCrawler {
        let html = loadHTML()
        return HomeCrawler(html: html)
    }
    
    func loadHTML() -> String {
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
    
    private var mockRecentComics: [[String: Any]] {
        return [
            [
                "id": "239421",
                "title": "灰姑娘的哥哥們 Brothers of Cinderella [零星漢化組x禁漫天堂]",
                "image": "https://cdn-msp.18comic.org/media/albums/239421_3x4.jpg?v=1675312840",
                "authors": [
                    "HanNyang",
                    "L.Y."
                ],
                "tags": [
                    "女性向",
                    "韓漫",
                    "連載中"
                ],
                "category": "單本",
                "subCategory": "漢化",
                "likesCount": "4K"
            ],
            [
                "category": "單本",
                "image": "https://cdn-msp.18comic.org/media/albums/263004_3x4.jpg?v=1675312840",
                "title": "從指尖開始的熱情 ～青梅竹馬是消防員～[川野タニシ] 指先から本気の熱情～チャラ男消防士はまっすぐな目で私を抱いた～[最愛福瑞漢化組*禁漫天堂]",
                "likesCount": "26.4K",
                "authors": [
                    "川野タニシ"
                ],
                "subCategory": "漢化",
                "id": "263004",
                "tags": [
                    "劇情向",
                    "動畫化",
                    "女性向",
                    "中文"
                ]
            ],
            [
                "likesCount": "28.6K",
                "tags": [
                    "全彩",
                    "百合",
                    "劇情向",
                    "完結",
                    "中文"
                ],
                "image": "https://cdn-msp.18comic.org/media/albums/278762_3x4.jpg?v=1675312840",
                "subCategory": "漢化",
                "authors": [
                    "박미남",
                    "조상덕",
                    "朴美男"
                ],
                "title": "討厭的女人/讨厌的女人 [박미남/조상덕] [不咕鳥漢化組X禁漫天堂]",
                "id": "278762",
                "category": "單本"
            ],
            [
                "image": "https://cdn-msp.18comic.org/media/albums/401754_3x4.jpg?v=1675312840",
                "subCategory": "青年漫",
                "category": "單本",
                "likesCount": "2.2K",
                "tags": [
                    "青年漫",
                    "中文",
                    "連載",
                    "禁漫漢化組"
                ],
                "authors": [
                    "MissBlack"
                ],
                "title": "Ziggurat[禁漫漢化組][MissBlack]ジグラット",
                "id": "401754"
            ],
            [
                "tags": [
                    "青年漫",
                    "巨乳",
                    "出軌",
                    "NTR",
                    "熟女",
                    "人妻",
                    "劇情向",
                    "中文"
                ],
                "subCategory": "青年漫",
                "image": "https://cdn-msp.18comic.org/media/albums/277707_3x4.jpg?v=1675218287",
                "id": "277707",
                "category": "單本",
                "title": "异世界不伦勇者/異世界不倫勇者 [枫叶汉化] [いのまる 大井昌和] 異世界不倫～魔王討伐から十年、妻とはレスの元勇者と、夫を亡くした女戦士～",
                "authors": [
                    "いのまる",
                    "大井昌和"
                ],
                "likesCount": "65.7K"
            ],
            [
                "subCategory": "青年漫",
                "title": "扑杀粉色系～性犯罪者处刑人～ [灰羽社漢化組] [山本晃司] 撲殺ピンク～性犯罪者処刑人～",
                "id": "334965",
                "authors": [
                    "山本晃司"
                ],
                "category": "單本",
                "likesCount": "11.3K",
                "tags": [
                    "青年漫",
                    "女高中生",
                    "暴力",
                    "中文",
                    "連載中"
                ],
                "image": "https://cdn-msp.18comic.org/media/albums/334965_3x4.jpg?v=1675218299"
            ],
            [
                "title": "冰戀 [禁漫天堂] 冰上的愛",
                "likesCount": "28.9K",
                "authors": [
                    "saint",
                    "",
                    "enti"
                ],
                "subCategory": "漢化",
                "id": "356196",
                "tags": [
                    "全彩",
                    "劇情向",
                    "巨乳",
                    "中文"
                ],
                "category": "單本",
                "image": "https://cdn-msp.18comic.org/media/albums/356196_3x4.jpg?v=1675218253"
            ],
            [
                "category": "單本",
                "title": "H校園不登出 [禁漫漢化組]",
                "likesCount": "35.8K",
                "id": "407773",
                "tags": [
                    "全彩",
                    "劇情向",
                    "中文",
                    "禁漫漢化組"
                ],
                "authors": [
                    "Feel",
                    "MALPOI"
                ],
                "image": "https://cdn-msp.18comic.org/media/albums/407773_3x4.jpg?v=1675218275",
                "subCategory": "漢化"
            ],
            [
                "title": "落日感染力 [艶々] 落日のパトス",
                "authors": [
                    "艶々"
                ],
                "likesCount": "5.1K",
                "tags": [
                    "青年漫",
                    "巨乳",
                    "教師",
                    "劇情向",
                    "中文"
                ],
                "id": "25654",
                "category": "單本",
                "subCategory": "青年漫",
                "image": "https://cdn-msp.18comic.org/media/albums/25654_3x4.jpg?v=1675129100"
            ],
            [
                "id": "225952",
                "image": "https://cdn-msp.18comic.org/media/albums/225952_3x4.jpg?v=1675134623",
                "authors": [
                    "山本亮平"
                ],
                "title": "早乙女姊妹為了漫畫奮不顧身![風的工房][山本亮平] 早乙女姉妹は漫画のためなら!",
                "tags": [
                    "青年漫",
                    "劇情向",
                    "非H",
                    "中文"
                ],
                "category": "單本",
                "subCategory": "青年漫",
                "likesCount": "3.4K"
            ],
            [
                "category": "單本",
                "image": "https://cdn-msp.18comic.org/media/albums/287234_3x4.jpg?v=1675129118",
                "authors": [
                    "双龍"
                ],
                "tags": [
                    "青年漫",
                    "劇情向",
                    "中文",
                    "連載中",
                    "纯炮友"
                ],
                "id": "287234",
                "title": "这样的比较好 [双龍] こういうのがいい [禁漫天堂]",
                "likesCount": "74.8K",
                "subCategory": "青年漫"
            ],
            [
                "category": "單本",
                "id": "401194",
                "subCategory": "青年漫",
                "likesCount": "3.4K",
                "image": "https://cdn-msp.18comic.org/media/albums/401194_3x4.jpg?v=1675134160",
                "title": "异世界支配的skilltake [柑橘ゆすら 笠原巴] 異世界支配のスキルテイカー ゼロから始める奴隷ハーレム",
                "authors": [
                    "柑橘ゆすら",
                    "笠原巴"
                ],
                "tags": [
                    "青年漫",
                    "巨乳",
                    "強暴",
                    "劇情向",
                    "中文"
                ]
            ],
            [
                "id": "401755",
                "tags": [
                    "青年漫",
                    "搞笑",
                    "劇情向",
                    "連載",
                    "中文",
                    "禁漫漢化組"
                ],
                "category": "單本",
                "title": "全裸轉生異世界 [禁漫漢化組] [狐谷まどか , あしまと☆ょいか] 異世界に転生したら全裸にされた",
                "subCategory": "青年漫",
                "image": "https://cdn-msp.18comic.org/media/albums/401755_3x4.jpg?v=1675133769",
                "authors": [
                    "狐谷まどか",
                    "あしまと☆ょいか"
                ],
                "likesCount": "4.3K"
            ],
            [
                "authors": [
                    "Bolp",
                    "アビョ4"
                ],
                "image": "https://cdn-msp.18comic.org/media/albums/402868_3x4.jpg?v=1675129104",
                "likesCount": "5K",
                "title": "肌膚之親的好友 [禁漫漢化組]",
                "tags": [
                    "韓漫",
                    "中文",
                    "連載中",
                    "禁漫漢化組"
                ],
                "id": "402868",
                "category": "單本",
                "subCategory": "漢化"
            ],
            [
                "title": "催眠软件是无效的 [禁漫天堂]",
                "subCategory": "漢化",
                "authors": [
                    "BalBalTa",
                    "SanFU"
                ],
                "image": "https://cdn-msp.18comic.org/media/albums/410858_3x4.jpg?v=1675129108",
                "id": "410858",
                "tags": [
                    "全彩",
                    "催眠",
                    "後宮",
                    "劇情向",
                    "中文"
                ],
                "category": "單本",
                "likesCount": "7.1K"
            ],
            [
                "image": "https://cdn-msp.18comic.org/media/albums/185023_3x4.jpg?v=1675053773",
                "subCategory": "漢化",
                "tags": [
                    "超長篇",
                    "劇情向",
                    "全彩",
                    "女高中生",
                    "純愛",
                    "校服",
                    "過膝襪",
                    "校園",
                    "馬尾",
                    "巨乳",
                    "連褲襪",
                    "野砲",
                    "中文",
                    "青梅竹馬",
                    "禁漫書庫"
                ],
                "category": "單本",
                "id": "185023",
                "title": "竟然被青梅竹馬弄到高潮…！同居初日就因吵架做愛 [戸ヶ里憐] 幼馴染にイかされるなんて…!同居初日に喧嘩エッチ",
                "authors": [
                    "戸ヶ里憐"
                ],
                "likesCount": "41.1K"
            ],
            [
                "title": "舞浜有希的高潮臉，只有身為社團教練的我才知道 [ももしか藤子] 舞浜有希のイキ顔は部活顧問の俺しか知らない [不咕鳥漢化組X禁漫天堂]",
                "image": "https://cdn-msp.18comic.org/media/albums/248002_3x4.jpg?v=1675053780",
                "likesCount": "46.2K",
                "authors": [
                    "ももしか藤子"
                ],
                "id": "248002",
                "tags": [
                    "全彩",
                    "劇情向",
                    "NTR",
                    "馬尾",
                    "性勒索",
                    "短褲",
                    "出軌",
                    "肌肉",
                    "連載中",
                    "中文"
                ],
                "category": "單本",
                "subCategory": "漢化"
            ],
            [
                "image": "https://cdn-msp.18comic.org/media/albums/388396_3x4.jpg?v=1675053785",
                "id": "388396",
                "tags": [
                    "全彩",
                    "後宮",
                    "劇情向",
                    "巨乳",
                    "辦公女郎",
                    "中文"
                ],
                "subCategory": "漢化",
                "category": "單本",
                "title": "有债必偿[不咕鸟汉化组*禁漫天堂]",
                "authors": [
                    "Ssaneung",
                    "Pokpungssulgujee"
                ],
                "likesCount": "16.2K"
            ],
            [
                "id": "410272",
                "title": "偶像的配对游戏 [不咕鸟汉化组*禁漫天堂]",
                "image": "https://cdn-msp.18comic.org/media/albums/410272_3x4.jpg?v=1675053776",
                "tags": [
                    "全彩",
                    "偶像",
                    "後宮",
                    "癡女",
                    "斷面圖",
                    "巨乳",
                    "雙馬尾",
                    "中文",
                    "連載中"
                ],
                "likesCount": "37.1K",
                "category": "單本",
                "subCategory": "漢化",
                "authors": [
                    "プリンガ",
                    "ハムリンガ",
                    "布丁加",
                    "黑丁加"
                ]
            ],
            [
                "id": "313833",
                "likesCount": "20.3K",
                "category": "單本",
                "image": "https://cdn-msp.18comic.org/media/albums/313833_3x4.jpg?v=1674982209",
                "authors": [
                    "NO.ゴメス",
                    "EKZ"
                ],
                "title": "我的同學是姬騎士[NO.ゴメス EKZ] 姫騎士がクラスメート!",
                "subCategory": "青年漫",
                "tags": [
                    "青年漫",
                    "巨乳",
                    "劇情向",
                    "中文"
                ]
            ]
        ]
    }
}
