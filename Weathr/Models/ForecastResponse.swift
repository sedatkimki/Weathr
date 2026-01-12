//
//  ForecastResponse.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let forecastResponse = try? JSONDecoder().decode(ForecastResponse.self, from: jsonData)

import Foundation

// MARK: - ForecastResponse
struct ForecastResponse: Codable {
    let location: Location
    let current: Current
    let forecast: Forecast
}

// MARK: - Forecast
struct Forecast: Codable {
    let forecastday: [Forecastday]
}

// MARK: - Forecastday
struct Forecastday: Codable {
    let date: String
    let dateEpoch: Int
    let day: Day

    enum CodingKeys: String, CodingKey {
        case date
        case dateEpoch = "date_epoch"
        case day
    }
}

// MARK: - Day
struct Day: Codable {
    let maxtempC, mintempC, avgtempC, maxwindKph: Double
    let avgvisKM: Double
    let avghumidity, dailyWillItRain, dailyChanceOfRain: Int
    let condition: Condition
    let uv: Double

    enum CodingKeys: String, CodingKey {
        case maxtempC = "maxtemp_c"
        case mintempC = "mintemp_c"
        case avgtempC = "avgtemp_c"
        case maxwindKph = "maxwind_kph"
        case avgvisKM = "avgvis_km"
        case avghumidity
        case dailyWillItRain = "daily_will_it_rain"
        case dailyChanceOfRain = "daily_chance_of_rain"
        case condition, uv
    }
}
