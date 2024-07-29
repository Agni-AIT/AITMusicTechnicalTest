//
//  MusicPlayerViewController.swift
//  AITMusicTechnicalTest
//
//  Created by Agni Muhammad on 29/07/24.
//

import UIKit

class MusicPlayerViewController: UIViewController {
    
    // UI Components
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let playerControlView = UIView()
    private let playPauseButton = UIButton()
    private let previousButton = UIButton()
    private let nextButton = UIButton()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let noResultsLabel = UILabel()
    
    private let viewModel: MusicViewModel
    
    init(viewModel: MusicViewModel = MusicViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTapGesture()
        setupAudioSession()
        title = "AIT Music Player"
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    private func setupTapGesture() {}
    
    private func setupAudioSession() {}

}

extension MusicPlayerViewController: UISearchBarDelegate {
    
}

extension MusicPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? CustomSongCell else {
            fatalError("Unable to dequeue CustomSongCell")
        }
        
        let song = viewModel.songs[indexPath.row]
        cell.configure(with: song, isPlaying: viewModel.isCurrentlyPlaying(index: indexPath.row))
        return cell
    }
    
}

extension MusicPlayerViewController: MusicViewModelDelegate {
    func viewModelDidUpdateSongs(_ viewModel: MusicViewModel) {
        
    }
    
    func viewModelDidUpdatePlayingState(_ viewModel: MusicViewModel) {
        
    }
    
    func viewModelDidUpdateLoadingState(_ viewModel: MusicViewModel) {
        
    }
    
    func viewModelDidEncounterError(_ viewModel: MusicViewModel, error: any Error) {
        
    }
    
    func viewModelDidStartPlayingMusic(_ viewModel: MusicViewModel) {
        
    }
    
    func viewModelDidUpdateCurrentSong(_ viewModel: MusicViewModel) {
        
    }
    
    
}
