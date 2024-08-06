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
    func viewModelDidUpdatePlayerProgress(_ viewModel: MusicViewModel, currentTime: Double, duration: Double)
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
    var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserverToken: Any?
    
    private let apiService: APIService
    
    private var debounceTimer: Timer?
    
    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    deinit {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
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
        
        addTimeObserver()
    }
    
    private func addTimeObserver() {
        let interval = CMTime(seconds: 1.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self, let currentItem = self.player?.currentItem else { return }
            
            let duration = currentItem.duration.seconds
            let currentTime = time.seconds
            self.delegate?.viewModelDidUpdatePlayerProgress(self, currentTime: currentTime, duration: duration)
        }
    }
    
    func isCurrentlyPlaying(index: Int) -> Bool {
        return currentSongIndex == index && isPlaying
    }
    
    func searchSongs(query: String) {
        debounceTimer?.invalidate()
        
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false, block: { _ in
            // Cancel the previous work item if it hasn't started yet
            self.searchWorkItem?.cancel()
            
            // If the query is empty, clear the results immediately
            if query.isEmpty {
                self.songs = []
                return
            }
            
            // Create a new work item
            let workItem = DispatchWorkItem { [weak self] in
                self?.performSearch(query: query)
            }
            
            // Save the new work item and dispatch it after a delay
            self.searchWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: workItem)
        })
        
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
