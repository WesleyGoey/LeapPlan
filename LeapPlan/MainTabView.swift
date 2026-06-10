//
//  MainTabView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ExploreView()
                .tabItem { Label("Explore", systemImage: "map.fill") }
                .tag(0)

            ChatView()
                .tabItem { Label("LeapBot", systemImage: "sparkles") }
                .tag(1)

            TripsView()
                .tabItem { Label("Trips", systemImage: "briefcase.fill") }
                .tag(2)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(3)
        }
        .tint(Color.leapPrimary)
    }
}

#Preview {
    MainTabView()
}
