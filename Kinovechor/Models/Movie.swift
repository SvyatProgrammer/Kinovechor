//
//  Movie.swift
//  Kinovechor
//
//  Created by Свят on 23.10.26.
//

import Foundation

struct TMDBResponse : Codable {
    let results : [Movie]
}

struct Movie : Codable, Identifiable {
    let id : Int
    let title : String
    let overview : String?
    let posterPath : String?
    let releaseDate : String?
    let voteAverage : Double?
    
    var posterURL : URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    var year : String {
        guard let date = releaseDate, date.count >= 4 else { return "-" }
        return String(date.prefix(4))
    }
    
    enum CodingKeys : String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
}
