//
//  WatchLoginPromptView.swift
//  Leaplan_Watch Watch App
//

import SwiftUI

struct WatchLoginPromptView: View {
    @ObservedObject var viewModel: WatchAppViewModel

    var body: some View {
        ZStack {
            // Pure OLED dark background
            Color.black.ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                // MARK: - Icon Container
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black)
                        .frame(width: 56, height: 56)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(Color(hex: "#50B498").opacity(0.6), lineWidth: 1.5)
                        )

                    Image(systemName: "iphone.gen2")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(Color(hex: "#50B498"))
                }

                // MARK: - Text Elements
                VStack(spacing: 6) {
                    Text("Login Required")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Please open LeapPlan on your iPhone to sync your trips.")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                Spacer()

                // MARK: - Action Button
                Button(action: {
                    viewModel.triggerManualSync()
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(hex: "#50B498"))
                            .frame(height: 40)

                        if viewModel.isSyncing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(0.9)
                        } else {
                            Text("Check Sync")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.black)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isSyncing)
                .padding(.horizontal, 4)
            }
            .padding()
        }
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    WatchLoginPromptView(viewModel: .mock(isLoggedIn: false, isSyncing: false))
}
