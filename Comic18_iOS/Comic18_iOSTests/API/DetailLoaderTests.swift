//
//  DetailLoaderTests.swift
//  Comic18_iOSTests
//
//  Created by Bang Chiang Liao on 2023/4/21.
//

import XCTest

final class DetailLoaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptionRequest()
    }

    // MARK: - Helper methods
    
    

}
