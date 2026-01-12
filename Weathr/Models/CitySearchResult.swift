//
//  CitySearchResult.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import Foundation

struct CitySearchResult: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let url: String
}
