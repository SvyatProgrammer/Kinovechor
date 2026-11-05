//
//  Movie.swift
//  Kinovechor
//
//  Created by Свят on 23.10.26.
//

import Foundation

// MARK: Movie
struct TMDBResponse : Codable {
    let results : [Movie]
}

struct Movie : Codable, Identifiable {
    let id : Int
    let title : String?
    let name : String?
    let overview : String?
    let posterPath : String?
    let releaseDate : String?
    let firstAirDate : String?
    let voteAverage : Double?
    let mediaType : String?
    let genreIds : [Int]?
    let genres : [Genre]?
    
    var displayTitle : String {
        return title ?? name ?? "Без названия"
    }
    
    var posterURL : URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    var year : String {
        let dateString = releaseDate ?? firstAirDate ?? ""
        if dateString.count >= 4 {
            return String(dateString.prefix(4))
        }
        return "Н/Д"
    }
    
    var genreNames : [String] {
            guard let ids = genreIds else { return [] }
            return ids.compactMap { genreMap[$0] }
        }
    
    var genreMap : [Int: String] {
        [
            28: "Боевик", 12: "Приключения", 16: "Мультфильм", 35: "Комедия",
            80: "Криминал", 99: "Документальный", 18: "Драма", 10751: "Семейный",
            14: "Фэнтези", 36: "Исторический", 27: "Ужасы", 10402: "Музыка",
            9648: "Детектив", 10749: "Мелодрама", 878: "Фантастика", 10770: "ТВ-фильм",
            53: "Триллер", 10752: "Военный", 37: "Вестерн",
            // Специфичные для сериалов:
            10759: "Экшн и Приключения", 10762: "Детский", 10763: "Новости",
            10764: "Реалити-шоу", 10765: "Фантастика и Фэнтези", 10766: "Мыльная опера",
            10767: "Ток-шоу", 10768: "Политика и История"
        ]
    }
    
    enum CodingKeys : String, CodingKey {
        case id, title, name, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case mediaType = "media_type"
        case genreIds = "genre_ids"
        case genres
    }
}

// MARK: TV seasons and series
struct TVDetailResponse : Codable {
    let numberOfSeasons : Int?
    let numberOfEpisodes : Int?
    
    enum CodingKeys : String, CodingKey {
        case numberOfSeasons = "number_of_seasons"
        case numberOfEpisodes = "number_of_episodes"
    }
}

// MARK: Creadits
struct CreditsResponse : Codable {
    let cast : [CastMember]
    let crew : [CrewMember]
}

struct CastMember : Codable, Identifiable {
    let id : Int
    let name : String
    let character : String?
    let profilePath : String?
    
    var profileURL : URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }
    
    enum CodingKeys : String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }
}

struct CrewMember : Codable, Identifiable {
    let id : Int
    let name : String
    let job : String
}

// MARK: Rewiew
struct RewiewResponse : Codable {
    let results :    [Rewiew]
}

struct Rewiew : Codable, Identifiable {
    let id : String
    let author : String
    let content : String
    let createdAt : String?
    let authorDetails: AuthorDetails?
    
    enum CodingKeys : String, CodingKey {
        case id, author, content
        case createdAt = "created_at"
        case authorDetails = "author_details"
    }
}

struct AuthorDetails : Codable {
    let rating : Double?
}

// MARK: Genre
struct Genre : Codable, Identifiable {
    let id : Int
    let name : String
}
