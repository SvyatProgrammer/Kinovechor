//
//  TMDBManager.swift
//  Kinovechor
//
//  Created by Свят on 23.10.26.
//

import Foundation
import Combine

class TMDBManager : ObservableObject {
    @Published var movies : [Movie] = []
    @Published var popularMovies : [Movie] = []
    @Published var isLoading : Bool = false
    @Published var errorMessage : String? = nil
    
    // MARK: API key from TMDB
    private let apiKey = "d98c30b65029dc642b14ca8079df9ffe"
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        fetchPopularMovies()
    }
    
    // MARK: Loading trends
    func fetchPopularMovies() {
        guard let url = URL(string: "https://api.themoviedb.org/3/trending/movie/day?api_key=\(apiKey)&language=ru-RU") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: TMDBResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue : { [weak self] response in
                self?.popularMovies = response.results
            }
            .store(in: &cancellables)
    }
    
    // MARK: Search movies
    func searchMovies(query : String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count > 1 else {
            movies = []
            return
        }
        
        guard let encodedQuery = trimmedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: "https://api.themoviedb.org/3/search/movie?api_key=\(apiKey)&query=\(encodedQuery)&language=ru-RU") else { return }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: TMDBResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] response in
                self?.movies = response.results
                if response.results.isEmpty {
                    self?.errorMessage = "Фильмы не найдены"
                }
            }
            .store(in: &cancellables)
    }
}
