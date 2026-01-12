//
//  DetailMetricCard.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import SwiftUI

struct DetailMetricCard: View {
    let iconName: String
    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .semibold))
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .opacity(0.9)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.18))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    DetailMetricCard(iconName: "drop.fill", value: "62%", title: "Humidity")
        .padding()
        .background(Color.blue)
}
