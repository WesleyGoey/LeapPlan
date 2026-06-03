//
//  MainTabView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab) // Melempar binding ke Home
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)
            
            ExploreView()
                .tabItem { Label("Explore", systemImage: "map.fill") }
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
