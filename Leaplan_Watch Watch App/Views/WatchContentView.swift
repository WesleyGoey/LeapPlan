//
//  WatchContentView.swift
//  Leaplan_Watch Watch App
//

import SwiftUI

struct WatchContentView: View {
    @StateObject var viewModel = WatchAppViewModel()

    var body: some View {
        Group {
            if !viewModel.isLoggedIn {
                WatchLoginPromptView(viewModel: viewModel)
            } else {
                NavigationStack {
                    WatchTripsView()
                }
            }
        }
        .animation(.easeInOut, value: viewModel.isLoggedIn)
    }
}

#Preview {
    WatchContentView()
}
