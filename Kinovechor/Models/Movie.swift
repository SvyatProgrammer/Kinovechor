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
    
    enum CodingKeys : String, CodingKey {
        case id, title, name, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case voteAverage = "vote_average"
        case mediaType = "media_type"
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
