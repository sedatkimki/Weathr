//
//  HomeView.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var vm = HomeViewModel()
    @State private var isPresentingAddCity = false
    var body: some View {
        NavigationStack {
            Group {
                if vm.displayCities.isEmpty {
                    EmptyStateView(
                        title: "No cities yet",
                        message: "Add a city to start tracking the weather.",
                    )
                } else {
                    List {
                        ForEach(vm.displayCities, id: \.location.name) { city in
                            NavigationLink {
                                CityDetailView(city: city)
                            } label: {
                                CityRowView(city: city)
                            }
                        }
                        .onDelete { offsets in
                            vm.deleteCity(at: offsets, using: modelContext)
                        }
                    }
                }
            }
            .navigationTitle("Weathr")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddCity = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add city")
                }
            }
            .refreshable {
                await vm.loadCities(using: modelContext)
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Text(vm.usedCacheOnLastLoad ? "Cache: used" : "Cache: not used")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.thinMaterial)
            }
            .task {
                await vm.loadCities(using: modelContext)
            }
            .sheet(isPresented: $isPresentingAddCity) {
                AddCityView { city in
                    vm.addCity(city, using: modelContext)
                    Task {
                        await vm.loadCities(using: modelContext)
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    HomeView()
}
