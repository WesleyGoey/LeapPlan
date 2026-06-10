//
//  WatchContentView.swift
//  Leaplan_Watch Watch App
//
//  Created by Wesley Goey on 10/06/26.
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
