//
//  SplashView.swift
//  Weathr
//
//  Created by sedat korkmaz on 12.01.2026.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            HomeView()
                .transition(.opacity)
        } else {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.7), Color.cyan.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 12) {
                    Image(systemName: "cloud.sun.fill")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Weathr")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Your weather, at a glance")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                withAnimation(.easeInOut(duration: 0.4)) {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
