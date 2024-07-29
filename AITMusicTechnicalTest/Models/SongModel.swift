//
//  SongModel.swift
//  AITMusicTechnicalTest
//
//  Created by Agni Muhammad on 29/07/24.
//

import Foundation

struct Song: Identifiable, Equatable {
    let id: Int64
    let title: String?
    let artist: String?
    let previewURL: String?
    let artworkURL: String?
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title && lhs.artist == rhs.artist && lhs.previewURL == rhs.previewURL && lhs.artworkURL == rhs.artworkURL
    }
}

struct iTunesSearchResponse: Codable {
    let results: [iTunesTrack]
}

struct iTunesTrack: Codable {
    let trackId: Int64
    let trackName: String?
    let artistName: String?
    let previewURL: String?
    let artworkURL100: String?
}
