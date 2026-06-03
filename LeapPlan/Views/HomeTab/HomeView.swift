//
//  HomeView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LeapPlan")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#00ADB5"))
                            Text("Plan your next adventure")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Circle()
                            .fill(Color(hex: "#00ADB5"))
                            .frame(width: 45, height: 45)
                            .overlay(Text("SJ").foregroundColor(.white).bold())
                    }
                    .padding(.horizontal)
                    
                    // Recent Trip Section
                    if let trip = viewModel.recentTrip {
                        NavigationLink(destination: TripDetailView(trip: trip)) {
                            RecentTripCard(trip: trip)
                                .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Trending Section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("🔥 Trending")
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if viewModel.isLoading {
                            ProgressView().padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(viewModel.trendingPlaces, id: \.fsq_place_id) { place in
                                        TrendingCard(place: place)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Immersive Explore Feed (TikTok Style)
                    VStack(alignment: .leading) {
                        HStack {
                            Text("🌍 Explore Destinations")
                                .font(.title3)
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if !viewModel.trendingPlaces.isEmpty {
                            ExploreFeedView(places: viewModel.trendingPlaces)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .onAppear {
                // TIDAK PERLU PARAMETER USER ID LAGI.
                // ViewModel akan otomatis membedakan Guest dan User Login lewat AuthService
                viewModel.loadDashboardData()
            }
        }
    }
}

#Preview{
    HomeView()
}
