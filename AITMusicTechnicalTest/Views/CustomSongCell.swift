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
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        playingIcon.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: playingIcon.leadingAnchor, constant: -8),
            
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            artistLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            artistLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            playingIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            playingIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            playingIcon.widthAnchor.constraint(equalToConstant: 20),
            playingIcon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        playingIcon.tintColor = .systemGreen
        playingIcon.contentMode = .scaleAspectFit
    }
    
    func configure(with song: Song, isPlaying: Bool) {
        titleLabel.text = song.title
        artistLabel.text = song.artist
        playingIcon.image = isPlaying ? UIImage(systemName: "checkmark.circle.fill") : nil
    }
}
