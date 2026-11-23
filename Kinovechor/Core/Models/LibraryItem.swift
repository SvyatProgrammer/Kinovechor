//
//  LibraryItem.swift
//  Kinovechor
//
//  Created by Свят on 9.11.26.
//

import Foundation
import SwiftUI

enum WatchStatus : String, Codable, CaseIterable, Identifiable {
    static let statuses = [WatchStatus.planned.id, WatchStatus.watching.id, WatchStatus.watched.id]
    
    var id : String { self.rawValue }
    var color : Color {
        switch self {
        case .planned:
            return .blue
        case .watching:
            return .orange
        case .watched:
            return .green
        }
    }
    
    case planned = "В планах"
    case watching = "Смотрим"
    case watched = "Просмотрено"
    
    static func color(for rawValue : String) -> Color {
        return WatchStatus(rawValue: rawValue)?.color ?? .red
    }
}

enum GroupType : String, Codable, CaseIterable, Identifiable {
    static let groups = [GroupType.main.id, GroupType.marvel.id, GroupType.dc.id]
    
    var id : String { self.rawValue }
    var color : Color {
        switch self {
        case .main:
            return .gray
        case .marvel:
            return .red
        case .dc:
            return .blue
        }
    }
    
    case main = "Основная"
    case marvel = "Marvel"
    case dc = "DC"
    
    static func color(for rawValue : String) -> Color {
        return GroupType(rawValue: rawValue)?.color ?? .gray
    }
}

enum SortOption : String, CaseIterable, Identifiable {
    var id : String { self.rawValue }
    
    case defaultOrder = "По умолчанию"
    case titleAsc = "А-Я"
    case titleDesc = "Я-А"
    case tmdbRating = "По рейтингу"
    case roomRating = "По рейтингу комнаты"
}

struct LibraryItem : Codable, Identifiable {
    let id : Int
    let title : String
    let posterPath : String?
    let mediaType : String?
    let year : String
    let voteAverage : Double?
    let genreIds : [Int]?
    let overview : String?

    var status : String
    var group : String
    var comment : String
    var rating : Double?
    
    var watchedSeason : Int?
    var watchedEpisode : Int?
    var watchedMinutes : Int?
    
    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    var genreNames : [String] {
        guard let ids = genreIds else { return [] }
        return ids.compactMap { Genre.genreMap[$0] }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "title": title,
            "posterPath": posterPath as Any,
            "mediaType": mediaType as Any,
            "year": year,
            "voteAverage": voteAverage as Any,
            "genreIds": genreIds as Any,
            "overview": overview as Any,
            "status": status,
            "group": group,
            "comment": comment,
            "rating": rating as Any,
            "watchedSeason": watchedSeason as Any,
            "watchedEpisode": watchedEpisode as Any,
            "watchedMinutes": watchedMinutes as Any
        ]
    }
}
