//
//  WeatherCache.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import Foundation
import SwiftData

@Model
final class WeatherCache {
    @Attribute(.unique) var key: String
    var query: String
    var kind: String
    var payload: Data
    var updatedAt: Date

    init(key: String, query: String, kind: String, payload: Data, updatedAt: Date = .now) {
        self.key = key
        self.query = query
        self.kind = kind
        self.payload = payload
        self.updatedAt = updatedAt
    }
}

@MainActor
final class WeatherStore {
    private let context: ModelContext
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(context: ModelContext) {
        self.context = context
    }

    func saveCurrent(_ response: WeatherResponse, query: String) throws {
        try save(response, key: cacheKey(kind: "current", query: query, days: nil), kind: "current", query: query)
    }

    func loadCurrent(query: String) throws -> WeatherResponse? {
        try load(key: cacheKey(kind: "current", query: query, days: nil))
    }

    func saveForecast(_ response: ForecastResponse, query: String, days: Int) throws {
        try save(response, key: cacheKey(kind: "forecast", query: query, days: days), kind: "forecast", query: query)
    }

    func loadForecast(query: String, days: Int) throws -> ForecastResponse? {
        try load(key: cacheKey(kind: "forecast", query: query, days: days))
    }

    private func save<T: Encodable>(_ value: T, key: String, kind: String, query: String) throws {
        let data = try encoder.encode(value)
        if let existing = try fetchCache(forKey: key) {
            existing.payload = data
            existing.updatedAt = .now
            existing.query = query
            existing.kind = kind
        } else {
            let cache = WeatherCache(key: key, query: query, kind: kind, payload: data)
            context.insert(cache)
        }
        try context.save()
    }

    private func load<T: Decodable>(key: String) throws -> T? {
        guard let cache = try fetchCache(forKey: key) else {
            return nil
        }
        return try decoder.decode(T.self, from: cache.payload)
    }

    private func fetchCache(forKey key: String) throws -> WeatherCache? {
        let predicate = #Predicate<WeatherCache> { $0.key == key }
        let descriptor = FetchDescriptor<WeatherCache>(predicate: predicate)
        return try context.fetch(descriptor).first
    }

    private func cacheKey(kind: String, query: String, days: Int?) -> String {
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let days {
            return "\(kind)|\(normalized)|\(days)"
        }
        return "\(kind)|\(normalized)"
    }
}
