//
//  HomeViewModel.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//


import Foundation
import SwiftData

@Observable
final class HomeViewModel {

    // MARK: - State
    private(set) var state: ViewState<[WeatherResponse]> = .idle
    private let weatherService = WeatherService.shared
    private let cityQueries = ["Istanbul", "Ankara"]
    private(set) var usedCacheOnLastLoad: Bool = false

    // MARK: - Derived values (View convenience)
    var cities: [WeatherResponse] {
        state.value ?? []
    }

    var isLoading: Bool {
        state.isLoading
    }

    // MARK: - Actions
    @MainActor
    func loadCities(using context: ModelContext) async {
        usedCacheOnLastLoad = false
        state = .loading
        do {
            let result = try await fetchCitiesWeather(using: context)
            state = .content(result)
        } catch {
            state = .failed(message: error.localizedDescription)
        }
    }

    // MARK: - Data source (placeholder)
    @MainActor
    private func fetchCitiesWeather(using context: ModelContext) async throws -> [WeatherResponse] {
        let store = WeatherStore(context: context)
        var results: [WeatherResponse] = []
        var lastError: Error?
        var usedCache = false

        for city in cityQueries {
            do {
                let response = try await weatherService.fetchCurrent(query: city)
                try store.saveCurrent(response, query: city)
                results.append(response)
            } catch {
                if let cached = try store.loadCurrent(query: city) {
                    results.append(cached)
                    usedCache = true
                } else {
                    lastError = error
                }
            }
        }

        if results.isEmpty, let lastError {
            throw lastError
        }

        usedCacheOnLastLoad = usedCache
        return results
    }

    @MainActor
    func loadForecast(for city: String, days: Int = 3, using context: ModelContext) async throws -> ForecastResponse {
        let store = WeatherStore(context: context)
        do {
            let response = try await weatherService.fetchForecast(query: city, days: days)
            try store.saveForecast(response, query: city, days: days)
            return response
        } catch {
            if let cached = try store.loadForecast(query: city, days: days) {
                return cached
            }
            throw error
        }
    }
}
