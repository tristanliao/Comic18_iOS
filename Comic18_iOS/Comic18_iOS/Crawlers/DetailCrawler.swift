//
//  DetailCrawler.swift
//  Comic18_iOS
//
//  Created by Bang Chiang Liao on 2023/4/17.
//

import Foundation
import SwiftSoup

public class DetailCrawler {
    private enum Constants {
        static let detailURL = "https://18comic.vip/album"
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let session: URLSession
    private let comicID: String
    private var detailHTML: String?
    
    public init(comicID: String, session: URLSession = .shared) {
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
    
    public func getDetailJSON(completion: @escaping (Result<[String: Any], Error>) -> Void) {
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
