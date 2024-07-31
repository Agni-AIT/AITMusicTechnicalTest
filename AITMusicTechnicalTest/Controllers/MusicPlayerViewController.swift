//
//  MusicPlayerViewController.swift
//  AITMusicTechnicalTest
//
//  Created by Agni Muhammad on 29/07/24.
//

import UIKit
import AVFoundation

class MusicPlayerViewController: UIViewController {
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let playerControlsView = UIView()
    private let playPauseButton = UIButton()
    private let previousButton = UIButton()
    private let nextButton = UIButton()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let noResultsLabel = UILabel()
    private let slider = UISlider()
    
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
        view.backgroundColor = .white
        
        // Setup search bar
        searchBar.placeholder = "Search for artist"
        searchBar.delegate = self
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomSongCell.self, forCellReuseIdentifier: "SongCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup player controls
        setupPlayerControls()
        view.addSubview(playerControlsView)
        playerControlsView.translatesAutoresizingMaskIntoConstraints = false
        playerControlsView.isHidden = true
        
        // Setup activity indicator
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup no results label
        setupNoResultsLabel()
        view.addSubview(noResultsLabel)
        noResultsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: playerControlsView.topAnchor),
            
            playerControlsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerControlsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerControlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            playerControlsView.heightAnchor.constraint(equalToConstant: 100),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            noResultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noResultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupNoResultsLabel() {
        noResultsLabel.text = "Let's swim into the deep..\nSearch an artist and disconnect from the world."
        noResultsLabel.textAlignment = .center
        noResultsLabel.numberOfLines = 0
        noResultsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        noResultsLabel.textColor = .gray
    }
    
    private func updateNoResultsLabelVisibility() {
        if viewModel.songs.isEmpty && !viewModel.isLoading {
            noResultsLabel.isHidden = false
            if searchBar.text?.isEmpty ?? true {
                noResultsLabel.text = "Let's swim into the deep..\nSearch an artist and disconnect from the world."
            } else {
                noResultsLabel.text = "No results found.\nPlease try a different search term."
            }
        } else {
            noResultsLabel.isHidden = true
        }
    }
    
    private func setupPlayerControls() {
        [previousButton, playPauseButton, nextButton, slider].forEach {
            //            $0.setTitleColor(.black, for: .normal)
            playerControlsView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        previousButton.setTitle("⏮", for: .normal)
        playPauseButton.setTitle("▶️", for: .normal)
        nextButton.setTitle("⏭", for: .normal)
        
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: playerControlsView.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: playerControlsView.centerYAnchor),
            
            previousButton.trailingAnchor.constraint(equalTo: playPauseButton.leadingAnchor, constant: -50),
            previousButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            nextButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 50),
            nextButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            
            slider.leadingAnchor.constraint(equalTo: playerControlsView.leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: playerControlsView.trailingAnchor, constant: -20),
            slider.bottomAnchor.constraint(equalTo: playerControlsView.bottomAnchor, constant: -10)
        ])
        
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func showPlayerControls() {
        guard playerControlsView.isHidden else { return }
        
        playerControlsView.transform = CGAffineTransform(translationX: 0, y: 100)
        playerControlsView.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.playerControlsView.transform = .identity
            self.tableView.frame = CGRect(x: self.tableView.frame.origin.x,
                                          y: self.tableView.frame.origin.y,
                                          width: self.tableView.frame.width,
                                          height: self.tableView.frame.height - 100)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func previousButtonTapped() {
        viewModel.previousSong()
    }
    
    @objc private func playPauseButtonTapped() {
        viewModel.togglePlayPause()
    }
    
    @objc private func nextButtonTapped() {
        viewModel.nextSong()
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        guard let duration = viewModel.player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(sender.value) * totalSeconds
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        viewModel.player?.seek(to: seekTime)
    }
}

extension MusicPlayerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchSongs(query: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension MusicPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? CustomSongCell else {
            fatalError("Unable to dequeue CustomSongCell")
        }
        
        let song = viewModel.songs[indexPath.row]
        cell.configure(with: song, isPlaying: viewModel.isCurrentlyPlaying(index: indexPath.row))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectSong(at: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
    }
}

extension MusicPlayerViewController: MusicViewModelDelegate {
    func viewModelDidUpdateSongs(_ viewModel: MusicViewModel) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateNoResultsLabelVisibility()
        }
    }
    
    func viewModelDidUpdatePlayingState(_ viewModel: MusicViewModel) {
        DispatchQueue.main.async {
            self.playPauseButton.setTitle(viewModel.isPlaying ? "⏸" : "▶️", for: .normal)
        }
    }
    
    func viewModelDidUpdateLoadingState(_ viewModel: MusicViewModel) {
        DispatchQueue.main.async {
            if viewModel.isLoading {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func viewModelDidEncounterError(_ viewModel: MusicViewModel, error: Error) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            self.updateNoResultsLabelVisibility()
        }
    }
    
    func viewModelDidStartPlayingMusic(_ viewModel: MusicViewModel) {
        DispatchQueue.main.async {
            self.showPlayerControls()
        }
    }
    
    func viewModelDidUpdateCurrentSong(_ viewModel: MusicViewModel) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func viewModelDidUpdatePlayerProgress(_ viewModel: MusicViewModel, currentTime: Double, duration: Double) {
        DispatchQueue.main.async {
            self.slider.value = Float(currentTime / duration)
        }
    }
}
