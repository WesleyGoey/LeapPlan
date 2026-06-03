//
//  GenerateItineraryView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//


import SwiftUI

struct GenerateItineraryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripViewModel // MENGGUNAKAN VM TERPUSAT
    
    @FocusState private var isDestinationFocused: Bool
    @State private var isGenerating: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#F9F9F9").ignoresSafeArea()
                .onTapGesture { isDestinationFocused = false }

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    sectionHeader(title: "DESTINATION")
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.and.ellipse").foregroundColor(Color(hex: "#50B498"))
                            TextField("Where do you want to go?", text: $viewModel.destinationForm)
                                .autocorrectionDisabled()
                                .focused($isDestinationFocused)
                        }
                        .padding().background(Color.white).cornerRadius(16).shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        
                        // Menyesuaikan dengan array autocompleteResults yang baru
                        if isDestinationFocused && !viewModel.autocompleteResults.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(viewModel.autocompleteResults, id: \.self) { placeName in
                                    Button {
                                        viewModel.destinationForm = placeName
                                        isDestinationFocused = false
                                    } label: {
                                        HStack(spacing: 16) {
                                            Image(systemName: "mappin.circle.fill").font(.title2).foregroundColor(.gray.opacity(0.8))
                                            Text(placeName).font(.body).foregroundColor(.primary).multilineTextAlignment(.leading)
                                            Spacer()
                                            Image(systemName: "arrow.up.backward").font(.caption).foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16).padding(.vertical, 14).background(Color.white)
                                    }
                                    if placeName != viewModel.autocompleteResults.last { Divider().padding(.leading, 50) }
                                }
                            }
                            .background(Color.white).cornerRadius(16).shadow(color: .black.opacity(0.15), radius: 10, y: 5).padding(.top, 8)
                        }
                    }
                    .zIndex(10)

                    sectionHeader(title: "TRAVEL DATES")
                    VStack(spacing: 0) {
                        DatePicker("Start Date", selection: $viewModel.startDateForm, displayedComponents: .date).padding()
                        Divider().padding(.horizontal)
                        DatePicker("End Date", selection: $viewModel.endDateForm, displayedComponents: .date).padding()
                    }
                    .background(Color.white).cornerRadius(16).shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                    .zIndex(1)

                    sectionHeader(title: "DAILY PREFERENCES")
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.dailyPreferences, id: \.dayNumber) { pref in dayTabButton(dayNumber: pref.dayNumber) }
                        }
                        .padding(.bottom, 8)
                    }

                    if let selectedIndex = viewModel.dailyPreferences.firstIndex(where: { $0.dayNumber == viewModel.selectedDayNumber }) {
                        VStack(spacing: 16) {
                            stepperCard(icon: "camera", title: "Places to visit", subtitle: "Attractions per day", value: $viewModel.dailyPreferences[selectedIndex].places)
                        }
                    }
                }
                .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 120)
            }
            .simultaneousGesture(DragGesture().onChanged({ _ in isDestinationFocused = false }))

            Button {
                Task {
                    isGenerating = true
                    do {
                        _ = try await viewModel.generateRandomTrip()
                        dismiss()
                    } catch { print("Gagal: \(error)") }
                    isGenerating = false
                }
            } label: {
                HStack {
                    Image(systemName: "bolt.fill").foregroundColor(.orange)
                    Text("Generate Trip").font(.headline)
                }
                .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 18).background(Color.leapPrimary).cornerRadius(16).shadow(color: Color.leapPrimary.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.horizontal, 20).padding(.bottom, 24)
            .disabled(viewModel.destinationForm.isEmpty || isGenerating)
            
            if isGenerating {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView().tint(.white).scaleEffect(1.5)
                    Text("Building your itinerary...").foregroundColor(.white).font(.headline)
                }
            }
        }
        .navigationTitle("Generate Itinerary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sectionHeader(title: String) -> some View { Text(title).font(.caption).fontWeight(.bold).foregroundColor(.gray).padding(.top, 8) }
    private func dayTabButton(dayNumber: Int) -> some View {
        let isSelected = viewModel.selectedDayNumber == dayNumber
        return Button { withAnimation { viewModel.selectedDayNumber = dayNumber } } label: { Text("Day \(dayNumber)").font(.subheadline.bold()).padding(.horizontal, 20).padding(.vertical, 10).background(isSelected ? Color.leapPrimary : Color.white).foregroundColor(isSelected ? .white : .leapSecondary).cornerRadius(20).shadow(color: .black.opacity(0.05), radius: 3, y: 2) }
    }
    private func stepperCard(icon: String, title: String, subtitle: String, value: Binding<Int>) -> some View {
        HStack { Image(systemName: icon).font(.title2).foregroundColor(.gray).frame(width: 32); VStack(alignment: .leading, spacing: 2) { Text(title).font(.headline).foregroundColor(.leapSecondary); Text(subtitle).font(.caption).foregroundColor(.gray) }; Spacer(); HStack(spacing: 16) { Button { if value.wrappedValue > 0 { value.wrappedValue -= 1 } } label: { Image(systemName: "minus").frame(width: 36, height: 36).background(Color.gray.opacity(0.1)).clipShape(Circle()).foregroundColor(.leapSecondary) }; Text("\(value.wrappedValue)").font(.title3.bold()).frame(width: 24); Button { value.wrappedValue += 1 } label: { Image(systemName: "plus").frame(width: 36, height: 36).background(Color.leapPrimary).clipShape(Circle()).foregroundColor(.white) } } }.padding().background(Color.white).cornerRadius(16).shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}
