//
//  AddToItinerarySheetView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


//
//  AddToItinerarySheetView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import SwiftUI

struct AddToItinerarySheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tripsViewModel = TripsViewModel()
    
    let place: FSQPlace
    
    // State Manajemen Navigasi Internal Sheet
    @State private var selectedTrip: Trip? = nil
    @State private var selectedDays: Set<Int> = []
    @State private var isSaving: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if tripsViewModel.isLoading {
                    ProgressView("Loading Itineraries...").padding(.top, 40)
                    Spacer()
                } else if selectedTrip == nil {
                    // LAYER 1: TAMPILKAN LIST ITINERARY YANG ADA
                    List(tripsViewModel.trips) { trip in
                        Button(action: {
                            withAnimation { selectedTrip = trip }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(trip.title).font(.headline).foregroundColor(.primary)
                                    Text(trip.locationName).font(.subheadline).foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                } else if let trip = selectedTrip {
                    // LAYER 2: TAMPILKAN CHECKLIST PILIHAN HARI (MULTI-DAY CHECK)
                    VStack(alignment: .leading) {
                        Text("Select Days for \(trip.title)")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        let totalDays = calculateTotalDays(start: trip.startDate, end: trip.endDate)
                        
                        List(1...totalDays, id: \.self) { dayNum in
                            Button(action: {
                                if selectedDays.contains(dayNum) { selectedDays.remove(dayNum) }
                                else { selectedDays.insert(dayNum) }
                            }) {
                                HStack {
                                    Text("Day \(dayNum)").font(.body).foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: selectedDays.contains(dayNum) ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundColor(selectedDays.contains(dayNum) ? Color(red: 0/255, green: 173/255, blue: 133/255) : .gray)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .listStyle(.plain)
                        
                        // Tombol Aksi Penyimpanan ke Firebase
                        Button(action: {
                            Task {
                                isSaving = true
                                await tripsViewModel.addPlaceToTrip(place: place, targetTrip: trip, selectedDays: selectedDays)
                                isSaving = false
                                // Alur kembali ke menu list itinerary awal setelah sukses menyimpan
                                withAnimation {
                                    selectedTrip = nil
                                    selectedDays.removeAll()
                                }
                            }
                        }) {
                            HStack {
                                if isSaving { ProgressView().tint(.white) }
                                else { Image(systemName: "checkmark") }
                                Text("Done adding to this Itinerary")
                            }
                            .font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding()
                            .background(selectedDays.isEmpty ? Color.gray : Color(red: 0/255, green: 173/255, blue: 133/255)).cornerRadius(12)
                        }
                        .disabled(selectedDays.isEmpty || isSaving)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(selectedTrip == nil ? "Choose Itinerary" : "Select Target Days")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let _ = selectedTrip {
                        Button("Back") { withAnimation { selectedTrip = nil } }
                    } else {
                        Button("Close") { dismiss() }
                    }
                }
            }
            .onAppear {
                tripsViewModel.loadUserTrips()
            }
        }
    }
    
    private func calculateTotalDays(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: end))
        return max(1, (components.day ?? 0) + 1)
    }
}