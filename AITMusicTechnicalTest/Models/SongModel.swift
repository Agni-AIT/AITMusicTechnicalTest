//
//  SongModel.swift
//  AITMusicTechnicalTest
//
//  Created by Agni Muhammad on 29/07/24.
//

import Foundation

struct Song: Identifiable, Equatable {
    let id: Int64
    let title: String
    let artist: String
    let previewUrl: String
    let artworkUrl: String
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title == rhs.title &&
               lhs.artist == rhs.artist &&
               lhs.previewUrl == rhs.previewUrl &&
               lhs.artworkUrl == rhs.artworkUrl
    }
}

struct ITunesSearchResponse: Codable {
    let results: [ITunesTrack]
}

struct ITunesTrack: Codable {
    let trackId: Int64
    let trackName: String
    let artistName: String
    let previewUrl: String
    let artworkUrl100: String
}
