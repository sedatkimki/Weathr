//
//  HomeViewModel.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//


import Foundation
import SwiftData
import SwiftUI

@Observable
final class HomeViewModel {

    // MARK: - State
    private(set) var state: ViewState<[WeatherResponse]> = .idle
    private let weatherService = WeatherService.shared
    private var cityQueries = ["Istanbul", "Ankara"]
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
    func addCity(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !cityQueries.contains(trimmed) {
            cityQueries.append(trimmed)
        }
    }

    @MainActor
    func deleteCity(at offsets: IndexSet) {
        let currentCities = cities
        let namesToRemove = offsets.compactMap { index in
            currentCities.indices.contains(index) ? currentCities[index].location.name : nil
        }

        if !namesToRemove.isEmpty {
            cityQueries.removeAll { namesToRemove.contains($0) }
        }

        if var value = state.value {
            value.remove(atOffsets: offsets)
            state = .content(value)
        }
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
