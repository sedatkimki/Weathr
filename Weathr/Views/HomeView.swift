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
    var body: some View {
        VStack(spacing: 12) {
            Text("Cities: \(vm.cities.count)")
            Text(vm.usedCacheOnLastLoad ? "Cache: used" : "Cache: not used")
            Button("Reload") {
                Task {
                    await vm.loadCities(using: modelContext)
                }
            }
        }
        .task {
            await vm.loadCities(using: modelContext)
        }
    }
}

#Preview {
    HomeView()
}
