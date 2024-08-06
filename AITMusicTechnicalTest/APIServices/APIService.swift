//
//  APIService.swift
//  AITMusicTechnicalTest
//
//  Created by Agni Muhammad on 29/07/24.
//

import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.decodingError(let lhsError), .decodingError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

class APIService {
    static let shared = APIService()
    var session: URLSession
    var urlComponents: URLComponents?
    
    init(session: URLSession = .shared) {
        self.session = session
        self.urlComponents = URLComponents(string: "https://itunes.apple.com/search")
    }
    
    func searchSongs(term: String, completion: @escaping (Result<[Song], APIError>) -> Void) {
        guard var urlComponents = self.urlComponents else {
            completion(.failure(.invalidURL))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "country", value: "ID"),
            URLQueryItem(name: "media", value: "music")
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.networkError(NSError(domain: "No Data", code: 0, userInfo: nil))))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(ITunesSearchResponse.self, from: data)
                let songs = searchResponse.results.map { Song(id: $0.trackId, title: $0.trackName, artist: $0.artistName, previewUrl: $0.previewUrl, artworkUrl: $0.artworkUrl100, collectionName: $0.collectionName) }
                completion(.success(songs))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
}
