//
//  HomeViewModel.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//


import Foundation

@Observable
final class HomeViewModel {

    // MARK: - State
    private(set) var state: ViewState<[WeatherResponse]> = .idle

    // MARK: - Derived values (View convenience)
    var cities: [WeatherResponse] {
        state.value ?? []
    }

    var isLoading: Bool {
        state.isLoading
    }

    // MARK: - Actions
    @MainActor
    func loadCities() async {
        state = .loading
        do {
            let result = try await fetchCitiesWeather()
            state = .content(result)
        } catch {
            state = .failed(message: error.localizedDescription)
        }
    }

    // MARK: - Data source (placeholder)
    private func fetchCitiesWeather() async throws -> [WeatherResponse] {
        // TODO: CityStore + WeatherService entegrasyonu
        return []
    }
}
