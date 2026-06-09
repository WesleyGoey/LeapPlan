//
//  WatchLoginPromptView.swift
//  Leaplan_Watch Watch App
//

import SwiftUI

struct WatchLoginPromptView: View {
    @ObservedObject var viewModel: WatchAppViewModel

    var body: some View {
        ZStack {
            // Main Background matching Trips view
            Color(hex: "#F2F2F7").ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()

                // MARK: - Icon Container
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .overlay(
                            Image(systemName: "iphone")
                                .font(.system(size: 28, weight: .regular))
                                .foregroundStyle(.black)
                        )

                    // Sync Badge overlaid
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#F2F2F7"))
                            .frame(width: 24, height: 24)
                        
                        Circle()
                            .fill(Color(hex: "#50B498"))
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .offset(x: 6, y: 6) // Push bottom right
                }
                .padding(.bottom, 6)

                // MARK: - Text Elements
                VStack(spacing: 4) {
                    Text("Login Required")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)

                    Text("Open LeapPlan on iPhone to\nsync trips.")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // MARK: - Action Button
                Button(action: {
                    viewModel.triggerManualSync()
                }) {
                    ZStack {
                        Capsule()
                            .fill(Color(hex: "#E5E5EA"))
                            .frame(height: 38)

                        if viewModel.isSyncing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(0.8)
                        } else {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Check Sync")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(.black)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isSyncing)
                .padding(.horizontal, 16)
                
                Spacer()
            }
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
