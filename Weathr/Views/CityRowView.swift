//
//  CityRowView.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import SwiftUI

struct CityRowView: View {
    let city: WeatherResponse

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            weatherIcon
            VStack(alignment: .leading, spacing: 4) {
                Text(city.location.name)
                    .font(.headline)
                Text(city.location.country)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(city.current.condition.text)
                    .font(.subheadline)
            }
            Spacer()
            Text("\(city.current.tempC, specifier: "%.1f")°")
                .font(.headline)
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 6)
    }

    private var weatherIcon: some View {
        Group {
            if let url = iconURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
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
        .frame(width: 36, height: 36)
    }

    private var iconURL: URL? {
        let iconPath = city.current.condition.icon
        if iconPath.hasPrefix("http") {
            return URL(string: iconPath)
        }
        return URL(string: "https:\(iconPath)")
    }
}

#Preview {
    CityRowView(
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
                condition: Condition(text: "Partly cloudy", icon: "//cdn.weatherapi.com/weather/64x64/day/116.png", code: 1003),
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
    .padding()
}
