//
//  AITMusicTechnicalTestTests.swift
//  AITMusicTechnicalTestTests
//
//  Created by Agni Muhammad on 30/07/24.
//

import XCTest
@testable import AITMusicTechnicalTest

final class MockAPIService: APIService {
    var searchSongsResult: Result<[Song], APIError>?
    
    override func searchSongs(term: String, completion: @escaping (Result<[Song], APIError>) -> Void) {
        if let result = searchSongsResult {
            completion(result)
        }
    }
}

final class MockDelegate: MusicViewModelDelegate {
    var updateSongsCalled = false
    var updatePlayingStateCalled = false
    var updateLoadingStateCalled = false
    var encounterErrorCalled = false
    var startPlayingMusicCalled = false
    var updateCurrentSongCalled = false
    
    func viewModelDidUpdateSongs(_ viewModel: MusicViewModel) {
        updateSongsCalled = true
    }
    
    func viewModelDidUpdatePlayingState(_ viewModel: MusicViewModel) {
        updatePlayingStateCalled = true
    }
    
    func viewModelDidUpdateLoadingState(_ viewModel: MusicViewModel) {
        updateLoadingStateCalled = true
    }
    
    func viewModelDidEncounterError(_ viewModel: MusicViewModel, error: Error) {
        encounterErrorCalled = true
    }
    
    func viewModelDidStartPlayingMusic(_ viewModel: MusicViewModel) {
        startPlayingMusicCalled = true
    }
    
    func viewModelDidUpdateCurrentSong(_ viewModel: MusicViewModel) {
        updateCurrentSongCalled = true
    }
}

final class MusicPlayerViewModelTests: XCTestCase {
    var viewModel: MusicViewModel!
    var mockAPIService: MockAPIService!
    var mockDelegate: MockDelegate!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        viewModel = MusicViewModel(apiService: mockAPIService)
        mockDelegate = MockDelegate()
        viewModel.delegate = mockDelegate
    }
    
    func testSearchSongsSuccess() {
        let expectation = self.expectation(description: "Search songs")
        
        let testSongs = [Song(id: 123, title: "Test Song", artist: "Test Artist", previewUrl: "https://example.com/preview", artworkUrl: "https://example.com/artwork")]
        mockAPIService.searchSongsResult = .success(testSongs)
        
        viewModel.searchSongs(query: "test")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertTrue(self.mockDelegate.updateLoadingStateCalled)
            XCTAssertTrue(self.mockDelegate.updateSongsCalled)
            XCTAssertEqual(self.viewModel.songs, testSongs)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSelectSong() {
        let testSongs = [
            Song(id: 1, title: "Song 1", artist: "Artist 1", previewUrl: "https://example.com/1", artworkUrl: "https://example.com/art1"),
            Song(id: 2, title: "Song 2", artist: "Artist 2", previewUrl: "https://example.com/2", artworkUrl: "https://example.com/art2")
        ]
        viewModel.setSongs(testSongs)
        
        viewModel.selectSong(at: 1)
        
        XCTAssertEqual(viewModel.currentSongIndex, 1)
        XCTAssertTrue(viewModel.isPlaying)
        XCTAssertTrue(mockDelegate.startPlayingMusicCalled)
        XCTAssertTrue(mockDelegate.updateCurrentSongCalled)
    }
    
    func testNextSong() {
        let testSongs = [
            Song(id: 1, title: "Song 1", artist: "Artist 1", previewUrl: "https://example.com/1", artworkUrl: "https://example.com/art1"),
            Song(id: 2, title: "Song 2", artist: "Artist 2", previewUrl: "https://example.com/2", artworkUrl: "https://example.com/art2")
        ]
        viewModel.setSongs(testSongs)
        viewModel.selectSong(at: 0)
        
        viewModel.nextSong()
        
        XCTAssertEqual(viewModel.currentSongIndex, 1)
        XCTAssertTrue(mockDelegate.startPlayingMusicCalled)
        XCTAssertTrue(mockDelegate.updateCurrentSongCalled)
    }
    
    func testPreviousSong() {
        let testSongs = [
            Song(id: 1, title: "Song 1", artist: "Artist 1", previewUrl: "https://example.com/1", artworkUrl: "https://example.com/art1"),
            Song(id: 2, title: "Song 2", artist: "Artist 2", previewUrl: "https://example.com/2", artworkUrl: "https://example.com/art2")
        ]
        viewModel.setSongs(testSongs)
        viewModel.selectSong(at: 1)
        
        viewModel.previousSong()
        
        XCTAssertEqual(viewModel.currentSongIndex, 0)
        XCTAssertTrue(mockDelegate.startPlayingMusicCalled)
        XCTAssertTrue(mockDelegate.updateCurrentSongCalled)
    }
    
    func testSearchSongsFailure() {
        let expectation = self.expectation(description: "Search songs failure")
        
        mockAPIService.searchSongsResult = .failure(APIError.networkError(NSError(domain: "TestError", code: 0, userInfo: nil)))
        
        viewModel.searchSongs(query: "test")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            XCTAssertTrue(self.mockDelegate.updateLoadingStateCalled)
            XCTAssertTrue(self.mockDelegate.encounterErrorCalled)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testTogglePlayPause() {
        viewModel.togglePlayPause()
        XCTAssertTrue(viewModel.isPlaying)
        XCTAssertTrue(mockDelegate.updatePlayingStateCalled)
        
        viewModel.togglePlayPause()
        XCTAssertFalse(viewModel.isPlaying)
        XCTAssertTrue(mockDelegate.updatePlayingStateCalled)
    }
}
