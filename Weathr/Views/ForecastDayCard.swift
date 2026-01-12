//
//  ForecastDayCard.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import SwiftUI

struct ForecastDayCard: View {
    let day: Forecastday

    var body: some View {
        VStack(spacing: 8) {
            Text(dayLabel)
                .font(.subheadline)
                .foregroundStyle(.white)
            weatherIcon
            Text("\(minTemp)° / \(maxTemp)°")
                .font(.footnote)
                .foregroundStyle(.white)
        }
        .frame(width: 110, height: 140)
        .background(Color.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var dayLabel: String {
        let formatter = Self.inputFormatter
        if let date = formatter.date(from: day.date) {
            return Self.outputFormatter.string(from: date)
        }
        return day.date
    }

    private var minTemp: String {
        String(format: "%.0f", day.day.mintempC)
    }

    private var maxTemp: String {
        String(format: "%.0f", day.day.maxtempC)
    }

    private var weatherIcon: some View {
        Group {
            if let url = iconURL {
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
        .frame(width: 36, height: 36)
        .foregroundStyle(.white)
    }

    private var iconURL: URL? {
        let iconPath = day.day.condition.icon
        if iconPath.hasPrefix("http") {
            return URL(string: iconPath)
        }
        return URL(string: "https:\(iconPath)")
    }

    private static let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let outputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

#Preview {
    ForecastDayCard(
        day: Forecastday(
            date: "2026-01-12",
            dateEpoch: 0,
            day: Day(
                maxtempC: 18.4,
                mintempC: 9.2,
                avgtempC: 13.1,
                maxwindKph: 21.0,
                avgvisKM: 9.0,
                avghumidity: 65,
                dailyWillItRain: 0,
                dailyChanceOfRain: 15,
                condition: Condition(text: "Sunny", icon: "//cdn.weatherapi.com/weather/64x64/day/113.png", code: 1000),
                uv: 4.0
            )
        )
    )
    .padding()
    .background(Color.blue)
}
