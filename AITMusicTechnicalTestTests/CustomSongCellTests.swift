//
//  CustomSongCellTests.swift
//  AITMusicTechnicalTestTests
//
//  Created by Agni Muhammad on 30/07/24.
//

import XCTest
@testable import AITMusicTechnicalTest

final class CustomSongCellTests: XCTestCase {
    var cell: CustomSongCell!
    
    override func setUp() {
        super.setUp()
        cell = CustomSongCell(style: .default, reuseIdentifier: "SongCell")
    }
    
    func testCellConfiguration() {
        let song = Song(id: 123, title: "Test Song", artist: "Test Artist", previewUrl: "https://example.com/preview", artworkUrl: "https://example.com/artwork", collectionName: "Test Collection")
        
        cell.configure(with: song, isPlaying: false)
        
        XCTAssertEqual(cell.titleLabel.text, "Test Song")
        XCTAssertEqual(cell.artistLabel.text, "Test Artist")
        XCTAssertNil(cell.playingIcon.image)
        
        cell.configure(with: song, isPlaying: true)
        
        XCTAssertEqual(cell.titleLabel.text, "Test Song")
        XCTAssertEqual(cell.artistLabel.text, "Test Artist")
        XCTAssertNotNil(cell.playingIcon.image)
    }
}
