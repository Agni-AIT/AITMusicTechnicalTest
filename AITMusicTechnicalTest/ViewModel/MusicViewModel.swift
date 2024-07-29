//
//  MusicViewModel.swift
//  AITMusicTechnicalTest
//
//  Created by Agni Muhammad on 29/07/24.
//

import Foundation
import AVFoundation

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
    
    private(set) var currentSongIndex: Int? {
        didSet {
            delegate?.viewModelDidUpdateCurrentSong(self)
        }
    }
    
    private(set) var isLoading: Bool = false {
        didSet {
            delegate?.viewModelDidUpdateLoadingState(self)
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
        
        guard let url = URL(string: song.previewURL ?? "") else {
            delegate?.viewModelDidEncounterError(self, error: NSError(domain: "Invalid URl", code: 0, userInfo: nil))
            
            return
        }
        
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        player?.play()
        isPlaying = true
        delegate?.viewModelDidStartPlayingMusic(self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem)
    }
    
    func isCurrentlyPlaying(index: Int) -> Bool {
        return currentSongIndex == index && isPlaying
    }
    
    func searchSongs(query: String) {
        searchWorkItem?.cancel()
        
        if query.isEmpty {
            songs = []
            return
        }
        
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.performSearch(query: query)
        }
        
        searchWorkItem  = workItem
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
    
    private func nextSong() {
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
    
    func setSongs(_ newSong: [Song]) {
        songs = newSong
    }
    
    @objc private func playerDidFinishPlaying() {
        nextSong()
    }
    
}
