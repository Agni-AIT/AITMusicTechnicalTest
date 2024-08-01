//
//  SongModel.swift
//  AITMusicTechnicalTest
//
//  Created by Agni Muhammad on 29/07/24.
//

import Foundation

struct Song: Identifiable {
    let id: Int64
    let title: String
    let artist: String
    let previewUrl: String
    let artworkUrl: String
    let collectionName: String
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
    let collectionName: String
}
