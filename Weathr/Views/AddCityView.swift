//
//  AddCityView.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import SwiftUI

struct AddCityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cityName = ""
    @State private var suggestions: [CitySearchResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchTask: Task<Void, Never>?
    private let weatherService = WeatherService.shared
    let onAdd: (String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("City") {
                    TextField("Enter city name", text: $cityName)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .onChange(of: cityName) { _, newValue in
                            scheduleSearch(for: newValue)
                        }
                }

                if isLoading {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Searching...")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } else if !suggestions.isEmpty {
                    Section("Suggestions") {
                        ForEach(suggestions) { item in
                            Button {
                                onAdd(item.name)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                    Text("\(item.region), \(item.country)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add City")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAdd(cityName)
                        dismiss()
                    }
                    .disabled(cityName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func scheduleSearch(for text: String) {
        searchTask?.cancel()
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            suggestions = []
            errorMessage = nil
            isLoading = false
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            await searchCities(query: trimmed)
        }
    }

    @MainActor
    private func searchCities(query: String) async {
        isLoading = true
        errorMessage = nil
        do {
            suggestions = try await weatherService.fetchSearch(query: query)
        } catch {
            suggestions = []
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    AddCityView { _ in }
}
