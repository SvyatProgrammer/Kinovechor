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
    @Published var cast : [CastMember] = []
    @Published var director : String = "Не указан"
    @Published var reviews : [Rewiew] = []
    @Published var isLoading : Bool = false
    @Published var isLoadingPopularMovies : Bool = false
    @Published var isLoadingCasts : Bool = false
    @Published var isLoafingReviews : Bool = false
    @Published var errorMessage : String? = nil
    @Published var numberOfSeasons : Int? = nil
    @Published var numberOfEpisodes : Int? = nil
    
    // MARK: API key from TMDB
    private let apiKey = "d98c30b65029dc642b14ca8079df9ffe"
    private var cancellables = Set<AnyCancellable>()
    
    
    init() {
        fetchPopularMovies()
    }
    
    // MARK: Loading trends
    func fetchPopularMovies() {
        guard let movieURL = URL(string: "https://api.themoviedb.org/3/trending/movie/day?api_key=\(apiKey)&language=ru-RU"),
              let tvURL = URL(string: "https://api.themoviedb.org/3/trending/tv/day?api_key=\(apiKey)&language=ru-RU") else { return }
         
        isLoadingPopularMovies = true
        errorMessage = nil
         
        let moviePublisher = URLSession.shared.dataTaskPublisher(for: movieURL)
            .map(\.data)
            .decode(type: TMDBResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .replaceError(with: [])
         
        let tvPublisher = URLSession.shared.dataTaskPublisher(for: tvURL)
            .map(\.data)
            .decode(type: TMDBResponse.self, decoder: JSONDecoder())
            .map { $0.results }
            .replaceError(with: [])
         
        Publishers.Zip(moviePublisher, tvPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingPopularMovies = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Ошибка загрузки: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] movies, tvShows in
                let combined = movies + tvShows
                
                self?.popularMovies = combined.sorted { ($0.voteAverage ?? 0) > ($1.voteAverage ?? 0) }
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
        
        guard let encodedQuery = trimmedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: "https://api.themoviedb.org/3/search/multi?api_key=\(apiKey)&query=\(encodedQuery)&language=ru-RU") else { return }
        
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
                self?.movies = response.results.filter { $0.mediaType == "movie" || $0.mediaType == "tv" || $0.mediaType == nil }
                if response.results.isEmpty {
                    self?.errorMessage = "Ничего не найдены"
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: Fetch movie data
    func fetchMovieData(movieId : Int, mediaType : String?) {
        self.numberOfSeasons = nil
        self.numberOfEpisodes = nil
        
        fetchCredits(movieId: movieId, mediaType: mediaType)
        fetchReviews(movieId: movieId, mediaType: mediaType)
        
        if mediaType == "tv" {
            fetchTVDetails(tvId: movieId)
        }
    }
    
    // MARK: Loading credits
    func fetchCredits(movieId : Int, mediaType : String?) {
        let type = (mediaType == "tv") ? "tv" : "movie"
        
        guard let url = URL(string: "https://api.themoviedb.org/3/\(type)/\(movieId)/credits?api_key=\(apiKey)&language=ru-RU") else { return }
        
        isLoadingCasts = true
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CreditsResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingCasts = false
                if case .failure(let error) = completion {
                    print("Ошибка загрузки актеров: \(error)")
                }
            } receiveValue: { [weak self] response in
                self?.cast = Array(response.cast.prefix(10))
                
                if let directorCrew = response.crew.first(where: { $0.job == "Director" || $0.job == "Series Director"}) {
                    self?.director = directorCrew.name
                } else if let firstCrew = response.crew.first {
                    self?.director = firstCrew.name
                } else {
                    self?.director = "Не указан"
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: Loading reviews
    func fetchReviews(movieId : Int, mediaType : String?) {
        let type = (mediaType == "tv") ? "tv" : "movie"
        
        guard let url = URL(string: "https://api.themoviedb.org/3/\(type)/\(movieId)/reviews?api_key=\(apiKey)") else { return }
        
        isLoafingReviews = true
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: RewiewResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoafingReviews = false
                if case .failure(let error) = completion {
                    print("Ошибка загрузки отзывов: \(error)")
                }
            } receiveValue: { [weak self] response in
                self?.reviews = Array(response.results.prefix(3))
            }
            .store(in: &cancellables)
    }
    
    // MARK: Loading tv details
    func fetchTVDetails(tvId : Int) {
        guard let url = URL(string: "https://api.themoviedb.org/3/tv/\(tvId)?api_key=\(apiKey)&language=ru-RU") else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: TVDetailResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Ошибка загрузки деталей сериала: \(error)")
                }
            } receiveValue: { [weak self] response in
                self?.numberOfSeasons = response.numberOfSeasons
                self?.numberOfEpisodes = response.numberOfEpisodes
            }
            .store(in: &cancellables)
    }
}
