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
                    "trackId": 120954025,
                    "trackName": "Upside Down",
                    "artistName": "Jack Johnson",
                    "collectionName": "Sing-a-Longs and Lullabies for the Film Curious George",
                    "previewUrl": "http://a1099.itunes.apple.com/r10/Music/f9/54/43/mzi.gqvqlvcq.aac.p.m4p",
                    "artworkUrl100": "http://a1.itunes.apple.com/r10/Music/3b/6a/33/mzi.qzdqwsel.100x100-75.jpg"
                }
            ]
        }
        """.data(using: .utf8)!
        
        mockSession.data = mockJSONResponse
        
        apiService.searchSongs(term: "test") { result in
            switch result {
            case .success(let songs):
                XCTAssertEqual(songs.count, 1)
                XCTAssertEqual(songs[0].id, 120954025)
                XCTAssertEqual(songs[0].title, "Upside Down")
                XCTAssertEqual(songs[0].artist, "Jack Johnson")
                XCTAssertEqual(songs[0].collectionName, "Sing-a-Longs and Lullabies for the Film Curious George")
                XCTAssertEqual(songs[0].previewUrl, "http://a1099.itunes.apple.com/r10/Music/f9/54/43/mzi.gqvqlvcq.aac.p.m4p")
                XCTAssertEqual(songs[0].artworkUrl, "http://a1.itunes.apple.com/r10/Music/3b/6a/33/mzi.qzdqwsel.100x100-75.jpg")
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
