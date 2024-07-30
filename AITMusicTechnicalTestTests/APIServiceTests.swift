//
//  APIServiceTests.swift
//  AITMusicTechnicalTestTests
//
//  Created by Agni Muhammad on 30/07/24.
//

import XCTest
@testable import AITMusicTechnicalTest

final class MockUrlSessionDataTask: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}

final class MockUrlSession: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    var data: Data?
    var error: Error?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        return MockUrlSessionDataTask {
            completionHandler(self.data, nil, self.error)
        }
    }
}

final class APIServiceTests: XCTestCase {
    var apiService: APIService!
    var mockSession: MockUrlSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockUrlSession()
        apiService = APIService(session: mockSession)
        apiService.urlComponents = URLComponents(string: "https://example.com/search")
    }
    
    func testSearchSongsSuccess() {
        let expectation = self.expectation(description: "Search songs")
        
        let mockJSONResponse = """
        {
            "resultCount": 1,
            "results": [
                {
                    "trackId": 1557247316,
                    "trackName": "Khoda",
                    "artistName": "Chepang",
                    "previewUrl": "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview114/v4/b6/82/d9/b682d9e4-5cb1-2f88-9d9e-6fef8bc2ccb5/mzaf_12964581893657811346.plus.aac.p.m4a",
                    "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/92/1c/9d/921c9d68-7755-8b65-a473-e43f6ca425c7/source/100x100bb.jpg"
                }
            ]
        }
        """.data(using: .utf8)!
        
        mockSession.data = mockJSONResponse
        
        apiService.searchSongs(term: "test") { result in
            switch result {
            case .success(let songs):
                XCTAssertEqual(songs.count, 1)
                XCTAssertEqual(songs[0].id, 1557247316)
                XCTAssertEqual(songs[0].title, "Khoda")
                XCTAssertEqual(songs[0].artist, "Chepang")
                XCTAssertEqual(songs[0].previewUrl, "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview114/v4/b6/82/d9/b682d9e4-5cb1-2f88-9d9e-6fef8bc2ccb5/mzaf_12964581893657811346.plus.aac.p.m4a")
                XCTAssertEqual(songs[0].artworkUrl, "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/92/1c/9d/921c9d68-7755-8b65-a473-e43f6ca425c7/source/100x100bb.jpg")
            case .failure(let error):
                XCTFail("Expected success, but got failure: \(error)")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSearchSongsFailure() {
        let expectation = self.expectation(description: "Search songs failure")
        
        mockSession.error = NSError(domain: "TestError", code: 0, userInfo: nil)
        
        apiService.searchSongs(term: "test") { result in
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                if case .networkError(let underlyingError) = error {
                    XCTAssertEqual(underlyingError.localizedDescription, NSError(domain: "TestError", code: 0, userInfo: nil).localizedDescription)
                } else {
                    XCTFail("Expected networkError, but got \(error)")
                }
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
