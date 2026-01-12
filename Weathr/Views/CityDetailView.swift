//
//  CityDetailView.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import SwiftUI
import SwiftData

struct CityDetailView: View {
    let city: WeatherResponse
    @Environment(\.modelContext) private var modelContext
    @State private var vm = CityDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text(city.location.name)
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    Text("\(city.current.tempC, specifier: "%.1f")°")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(.white)
                }

                HStack(spacing: 10) {
                    currentConditionIcon
                    Text(city.current.condition.text)
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Details Today")
                        .font(.headline)
                        .foregroundStyle(.white)

                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        DetailMetricCard(
                            iconName: "drop.fill",
                            value: "\(city.current.humidity)%",
                            title: "Humidity"
                        )
                        DetailMetricCard(
                            iconName: "wind",
                            value: "\(windSpeed) km/h",
                            title: "Wind Speed"
                        )
                        DetailMetricCard(
                            iconName: "thermometer.medium",
                            value: "\(feelsLikeTemp)°",
                            title: "Feels Like"
                        )
                        DetailMetricCard(
                            iconName: "sun.max.fill",
                            value: "\(city.current.uv)",
                            title: "UV Index"
                        )
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("5 Day Forecast")
                        .font(.headline)
                        .foregroundStyle(.white)

                    if vm.state.isLoading && vm.forecastDays.isEmpty {
                        ProgressView()
                            .tint(.white)
                    } else if let message = vm.state.errorMessage {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.9))
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(vm.forecastDays.prefix(5), id: \.date) { day in
                                    ForecastDayCard(day: day)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .padding()
        }
        .background(backgroundGradient.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.loadForecast(for: city.location.name, days: 5, using: modelContext)
        }
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
    }

    private var windSpeed: String {
        String(format: "%.0f", city.current.windKph)
    }

    private var feelsLikeTemp: String {
        String(format: "%.1f", city.current.feelslikeC)
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.blue.opacity(0.75), Color.cyan.opacity(0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var currentConditionIcon: some View {
        Group {
            if let url = conditionIconURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(.white)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "cloud")
                    @unknown default:
                        Image(systemName: "cloud")
                    }
                }
            } else {
                Image(systemName: "cloud")
            }
        }
        .frame(width: 42, height: 42)
        .foregroundStyle(.white)
    }

    private var conditionIconURL: URL? {
        let iconPath = city.current.condition.icon
        if iconPath.hasPrefix("http") {
            return URL(string: iconPath)
        }
        return URL(string: "https:\(iconPath)")
    }
}

#Preview {
    CityDetailView(
        city: WeatherResponse(
            location: Location(
                name: "Istanbul",
                region: "Marmara",
                country: "Turkey",
                lat: 41.01,
                lon: 28.97,
                tzID: "Europe/Istanbul",
                localtimeEpoch: 0,
                localtime: "2026-01-12 12:00"
            ),
            current: Current(
                lastUpdated: "2026-01-12 12:00",
                tempC: 12.4,
                isDay: 1,
                condition: Condition(text: "Partly cloudy", icon: "", code: 1003),
                windMph: 6.0,
                windKph: 10.0,
                windDegree: 180,
                windDir: "S",
                humidity: 60,
                cloud: 40,
                feelslikeC: 11.0,
                visKM: 10,
                uv: 3
            )
        )
    )
    .modelContainer(for: WeatherCache.self, inMemory: true)
}
