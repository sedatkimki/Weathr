//
//  EmptyStateView.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String
    let onAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.slash")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button(actionTitle) {
                onAction()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    EmptyStateView(
        title: "No cities yet",
        message: "Add a city to start tracking the weather.",
        actionTitle: "Add City",
        onAction: {}
    )
}
