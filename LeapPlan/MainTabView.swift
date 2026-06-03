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
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Explore")
                }
                .tag(1)
            
            TripsView()
                .tabItem {
                    Image(systemName: "briefcase.fill")
                    Text("Trips")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .tint(Color.leapPrimary) // Memastikan warna tab aktif mengikuti tema LeapPlan
    }
}

#Preview {
    MainTabView()
}
