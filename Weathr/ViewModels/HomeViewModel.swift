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
    private var cityQueries: [String] = []
    private(set) var usedCacheOnLastLoad: Bool = false
    private(set) var lastLoadedCities: [WeatherResponse] = []

    // MARK: - Derived values (View convenience)
    var cities: [WeatherResponse] {
        state.value ?? []
    }

    var displayCities: [WeatherResponse] {
        if isLoading {
            return lastLoadedCities
        }
        return cities
    }

    var isLoading: Bool {
        state.isLoading
    }

    // MARK: - Actions
    @MainActor
    func loadCities(using context: ModelContext) async {
        let previousState = state
        usedCacheOnLastLoad = false
        if let current = state.value {
            lastLoadedCities = current
        }
        state = .loading
        do {
            cityQueries = try loadCityQueries(using: context)
            if cityQueries.isEmpty {
                lastLoadedCities = []
                state = .content([])
                return
            }
            let result = try await fetchCitiesWeather(using: context)
            lastLoadedCities = result
            state = .content(result)
        } catch {
            if error is CancellationError {
                state = previousState
                return
            }
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
    func addCity(_ name: String, using context: ModelContext) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if !cityQueries.contains(trimmed) {
            cityQueries.append(trimmed)
            context.insert(CityRecord(name: trimmed))
            try? context.save()
        }
    }

    @MainActor
    func deleteCity(at offsets: IndexSet, using context: ModelContext) {
        let currentCities = state.value ?? lastLoadedCities
        let namesToRemove = offsets.compactMap { index in
            currentCities.indices.contains(index) ? currentCities[index].location.name : nil
        }

        if !namesToRemove.isEmpty {
            let normalizedNamesToRemove = namesToRemove.map { normalizeCityName($0) }

            // Update in-memory queries
            cityQueries.removeAll { normalizedNamesToRemove.contains(normalizeCityName($0)) }

            // Fetch and filter records in-memory to avoid calling global functions inside a predicate
            let descriptor = FetchDescriptor<CityRecord>()
            if let records = try? context.fetch(descriptor) {
                for record in records {
                    if normalizedNamesToRemove.contains(normalizeCityName(record.name)) {
                        context.delete(record)
                    }
                }
                try? context.save()
            }
        }

        if var value = state.value {
            value.remove(atOffsets: offsets)
            state = .content(value)
            lastLoadedCities = value
        }
    }

    @MainActor
    private func loadCityQueries(using context: ModelContext) throws -> [String] {
        let descriptor = FetchDescriptor<CityRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let records = try context.fetch(descriptor)
        return records.map(\.name)
    }

    private func normalizeCityName(_ name: String) -> String {
        name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
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
