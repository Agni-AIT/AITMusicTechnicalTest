//
//  MusicViewModel.swift
//  AITMusicTechnicalTest
//
//  Created by Agni Muhammad on 29/07/24.
//

import Foundation
import AVFoundation
import UIKit

protocol MusicViewModelDelegate: AnyObject {
    func viewModelDidUpdateSongs(_ viewModel: MusicViewModel)
    func viewModelDidUpdatePlayingState(_ viewModel: MusicViewModel)
    func viewModelDidUpdateLoadingState(_ viewModel: MusicViewModel)
    func viewModelDidEncounterError(_ viewModel: MusicViewModel, error: Error)
    func viewModelDidStartPlayingMusic(_ viewModel: MusicViewModel)
    func viewModelDidUpdateCurrentSong(_ viewModel: MusicViewModel)
}

class MusicViewModel {
    weak var delegate: MusicViewModelDelegate?
    
    private(set) var songs: [Song] = [] {
        didSet {
            currentSongIndex = nil
            delegate?.viewModelDidUpdateSongs(self)
        }
    }
    
    private(set) var isPlaying: Bool = false {
        didSet {
            delegate?.viewModelDidUpdatePlayingState(self)
        }
    }
    
    private(set) var isLoading: Bool = false {
        didSet {
            delegate?.viewModelDidUpdateLoadingState(self)
        }
    }
    
    private(set) var currentSongIndex: Int? {
        didSet {
            delegate?.viewModelDidUpdateCurrentSong(self)
        }
    }
    
    private var searchWorkItem: DispatchWorkItem?
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    
    private let apiService: APIService
    
    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    private func performSearch(query: String) {
        isLoading = true
        
        apiService.searchSongs(term: query) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch result {
            case .success(let songs):
                self.songs = songs
            case .failure(let error):
                self.songs = []
                self.delegate?.viewModelDidEncounterError(self, error: error)
            }
        }
    }
    
    private func playSong(at index: Int) {
        guard index < songs.count else { return }
        
        currentSongIndex = index
        let song = songs[index]
        
        guard let url = URL(string: song.previewUrl) else {
            delegate?.viewModelDidEncounterError(self, error: NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        player?.play()
        isPlaying = true
        delegate?.viewModelDidStartPlayingMusic(self)
        
        // Observe when the song ends
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
    }
    
    func isCurrentlyPlaying(index: Int) -> Bool {
        return currentSongIndex == index && isPlaying
    }
    
    func searchSongs(query: String) {
        // Cancel the previous work item if it hasn't started yet
        searchWorkItem?.cancel()
        
        // If the query is empty, clear the results immediately
        if query.isEmpty {
            songs = []
            return
        }
        
        // Create a new work item
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(query: query)
        }
        
        // Save the new work item and dispatch it after a delay
        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: workItem)
    }
    
    func togglePlayPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
        }
        isPlaying.toggle()
    }
    
    func nextSong() {
        guard let currentIndex = currentSongIndex else { return }
        let nextIndex = (currentIndex + 1) % songs.count
        playSong(at: nextIndex)
    }
    
    func previousSong() {
        guard let currentIndex = currentSongIndex else { return }
        let previousIndex = (currentIndex - 1 + songs.count) % songs.count
        playSong(at: previousIndex)
    }
    
    func selectSong(at index: Int) {
        playSong(at: index)
    }
    
    func setSongs(_ newSongs: [Song]) {
        songs = newSongs
    }
    
    @objc private func playerDidFinishPlaying() {
        nextSong()
    }
}
