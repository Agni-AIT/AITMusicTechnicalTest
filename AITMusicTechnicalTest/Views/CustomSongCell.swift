//
//  CustomSongCell.swift
//  AITMusicTechnicalTest
//
//  Created by Agni Muhammad on 29/07/24.
//

import UIKit

class CustomSongCell: UITableViewCell {
    let titleLabel = UILabel()
    let artistLabel = UILabel()
    let playingIcon = UIImageView()
    let albumImageView = UIImageView()
    let albumLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(playingIcon)
        contentView.addSubview(albumImageView)
        contentView.addSubview(albumLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        playingIcon.translatesAutoresizingMaskIntoConstraints = false
        albumImageView.translatesAutoresizingMaskIntoConstraints = false
        albumLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            albumImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            albumImageView.widthAnchor.constraint(equalToConstant: 40),
            albumImageView.heightAnchor.constraint(equalToConstant: 40),
            

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: albumImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: playingIcon.leadingAnchor, constant: -8),
            
            
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            
            albumLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 2),
            albumLabel.leadingAnchor.constraint(equalTo: artistLabel.leadingAnchor),
            albumLabel.trailingAnchor.constraint(equalTo: artistLabel.trailingAnchor),
            albumLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            
            playingIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playingIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            playingIcon.widthAnchor.constraint(equalToConstant: 20),
            playingIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        artistLabel.font = .systemFont(ofSize: 12, weight: .thin)
        albumLabel.font = .systemFont(ofSize: 10, weight: .ultraLight)
        
        playingIcon.tintColor = .systemGreen
        playingIcon.contentMode = .scaleAspectFit
        
        albumImageView.contentMode = .scaleAspectFit
        albumImageView.layer.cornerRadius = 4
        albumImageView.clipsToBounds = true
    }
    
    func configure(with song: Song, isPlaying: Bool) {
        titleLabel.text = song.title
        artistLabel.text = song.artist
        playingIcon.image = isPlaying ? UIImage(systemName: "waveform.path") : nil
        albumLabel.text = song.collectionName
        
        if let url = URL(string: song.artworkUrl) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.albumImageView.image = image
                    }
                }
            }
        }
    }
}
