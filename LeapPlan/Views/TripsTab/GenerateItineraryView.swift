//
//  GenerateItineraryView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import SwiftUI

struct GenerateItineraryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = GenerateItineraryViewModel()

    var onGenerate: ((RandomTripPreferences) -> Void)?

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#F9F9F9").ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // 1. Destination Section
                    sectionHeader(title: "DESTINATION")
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(Color(hex: "#50B498"))
                            
                            TextField("Where do you want to go?", text: $viewModel.destination)
                                .autocorrectionDisabled()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        
                        // DROPDOWN AUTOCOMPLETE MAPKIT
                        if viewModel.isShowingDropdown && !viewModel.searchResults.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(viewModel.searchResults, id: \.self) { placeName in
                                    Button {
                                        viewModel.destination = placeName
                                        viewModel.isShowingDropdown = false
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    } label: {
                                        HStack(spacing: 16) {
                                            Image(systemName: "mappin.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.gray.opacity(0.8))
                                            
                                            Text(placeName)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "arrow.up.backward")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .background(Color.white)
                                    }
                                    
                                    if placeName != viewModel.searchResults.last {
                                        Divider().padding(.leading, 50)
                                    }
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                            .padding(.top, 8)
                        }
                    }
                    .zIndex(10)

                    // 2. Travel Dates Section
                    sectionHeader(title: "TRAVEL DATES")
                    VStack(spacing: 0) {
                        DatePicker("Start Date", selection: $viewModel.startDate, displayedComponents: .date)
                            .padding()
                        Divider().padding(.horizontal)
                        DatePicker("End Date", selection: $viewModel.endDate, displayedComponents: .date)
                            .padding()
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    .zIndex(1)

                    // 3. Daily Preferences (TABBED)
                    sectionHeader(title: "DAILY PREFERENCES")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.dailyPreferences, id: \.dayNumber) { pref in
                                dayTabButton(dayNumber: pref.dayNumber)
                            }
                        }
                        .padding(.bottom, 8)
                    }

                    if let selectedIndex = viewModel.dailyPreferences.firstIndex(where: { $0.dayNumber == viewModel.selectedDayNumber }) {
                        VStack(spacing: 16) {
                            stepperCard(icon: "fork.knife", title: "Meals per day", subtitle: "Restaurants & cafes", value: $viewModel.dailyPreferences[selectedIndex].meals)
                            stepperCard(icon: "camera", title: "Places to visit", subtitle: "Attractions per day", value: $viewModel.dailyPreferences[selectedIndex].places)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 120)
            }

            // 4. Generate Button
            Button {
                let preferences = RandomTripPreferences(
                    locationName: viewModel.destination,
                    startDate: viewModel.startDate,
                    endDate: viewModel.endDate,
                    dailyPreferences: viewModel.dailyPreferences
                )
                onGenerate?(preferences)
                dismiss()
            } label: {
                HStack {
                    Image(systemName: "bolt.fill").foregroundColor(.orange)
                    Text("Generate Trip").font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.leapPrimary)
                .cornerRadius(16)
                .shadow(color: Color.leapPrimary.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .navigationTitle("Generate Itinerary")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews
    private func sectionHeader(title: String) -> some View {
        Text(title).font(.caption).fontWeight(.bold).foregroundColor(.gray).padding(.top, 8)
    }

    private func dayTabButton(dayNumber: Int) -> some View {
        let isSelected = viewModel.selectedDayNumber == dayNumber
        return Button {
            withAnimation { viewModel.selectedDayNumber = dayNumber }
        } label: {
            Text("Day \(dayNumber)")
                .font(.subheadline.bold())
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.leapPrimary : Color.white)
                .foregroundColor(isSelected ? .white : .leapSecondary)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
        }
    }

    private func stepperCard(icon: String, title: String, subtitle: String, value: Binding<Int>) -> some View {
        HStack {
            Image(systemName: icon).font(.title2).foregroundColor(.gray).frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).foregroundColor(.leapSecondary)
                Text(subtitle).font(.caption).foregroundColor(.gray)
            }
            Spacer()
            HStack(spacing: 16) {
                Button { if value.wrappedValue > 0 { value.wrappedValue -= 1 } } label: {
                    Image(systemName: "minus").frame(width: 36, height: 36).background(Color.gray.opacity(0.1)).clipShape(Circle()).foregroundColor(.leapSecondary)
                }
                Text("\(value.wrappedValue)").font(.title3.bold()).frame(width: 24)
                Button { value.wrappedValue += 1 } label: {
                    Image(systemName: "plus").frame(width: 36, height: 36).background(Color.leapPrimary).clipShape(Circle()).foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}
