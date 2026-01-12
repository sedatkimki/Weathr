//
//  CityDetailViewModel.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import Foundation
import SwiftData

@Observable
final class CityDetailViewModel {
    private(set) var state: ViewState<ForecastResponse> = .idle
    private let weatherService = WeatherService.shared

    @MainActor
    func loadForecast(for city: String, days: Int = 5, using context: ModelContext) async {
        state = .loading
        let store = WeatherStore(context: context)

        do {
            let response = try await weatherService.fetchForecast(query: city, days: days)
            try store.saveForecast(response, query: city, days: days)
            state = .content(response)
        } catch {
            if let cached = try? store.loadForecast(query: city, days: days) {
                state = .content(cached)
            } else {
                state = .failed(message: error.localizedDescription)
            }
        }
    }

    var forecastDays: [Forecastday] {
        state.value?.forecast.forecastday ?? []
    }
}
