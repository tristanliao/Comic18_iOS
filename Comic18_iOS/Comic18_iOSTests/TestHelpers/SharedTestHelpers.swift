//
//  SharedTestHelpers.swift
//  Comic18_iOSTests
//
//  Created by Bang Chiang Liao on 2023/2/18.
//

import Foundation

func loadHTML(fileName: String) -> Data? {
    guard let path = Bundle(for: URLProtocolStub.self).path(forResource: fileName, ofType: "html") else { return nil }
    guard let data = try? Data(contentsOf: URL(filePath: path)) else { return nil }
    
    return data
}

func loadJSON(fileName: String, file: StaticString = #filePath, line: UInt = #line) -> [[String: Any]] {
    guard let path = Bundle(for: URLProtocolStub.self).path(forResource: fileName, ofType: "json") else { return [] }
    guard let data = try? Data(contentsOf: URL(filePath: path)) else { return [] }
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
        return []
    }
    
    return json
}

var anyURLResponse: URLResponse {
    URLResponse()
}
