//
//  WeatherResponse.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: jsonData)

import Foundation

// MARK: - WeatherResponse
struct WeatherResponse: Codable, Equatable {
    let location: Location
    let current: Current
}

// MARK: - Current
struct Current: Codable, Equatable {
    let lastUpdated: String
    let tempC: Double
    let isDay: Int
    let condition: Condition
    let windMph, windKph: Double
    let windDegree: Int
    let windDir: String
    let humidity, cloud: Int
    let feelslikeC: Double
    let visKM, uv: Double

    enum CodingKeys: String, CodingKey {
        case lastUpdated = "last_updated"
        case tempC = "temp_c"
        case isDay = "is_day"
        case condition
        case windMph = "wind_mph"
        case windKph = "wind_kph"
        case windDegree = "wind_degree"
        case windDir = "wind_dir"
        case humidity, cloud
        case feelslikeC = "feelslike_c"
        case visKM = "vis_km"
        case uv
    }
}

// MARK: - Condition
struct Condition: Codable, Equatable {
    let text, icon: String
    let code: Int
}

// MARK: - Location
struct Location: Codable, Equatable {
    let name, region, country: String
    let lat, lon: Double
    let tzID: String
    let localtimeEpoch: Int
    let localtime: String

    enum CodingKeys: String, CodingKey {
        case name, region, country, lat, lon
        case tzID = "tz_id"
        case localtimeEpoch = "localtime_epoch"
        case localtime
    }
}
