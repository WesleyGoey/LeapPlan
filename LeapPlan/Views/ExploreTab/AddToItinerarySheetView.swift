//
//  AddToItinerarySheetView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import SwiftUI

struct AddToItinerarySheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tripViewModel = TripViewModel() // Inisialisasi ulang yang aman
    
    let place: FSQPlace
    @State private var selectedTrip: Trip? = nil
    @State private var selectedDays: Set<Int> = []
    @State private var isSaving: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if tripViewModel.isLoading {
                    ProgressView("Loading Itineraries...").padding(.top, 40)
                    Spacer()
                } else if tripViewModel.trips.isEmpty {
                    // PESAN JIKA BELUM PUNYA TRIP SAMA SEKALI ATAU GAGAL LOAD
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "briefcase").font(.system(size: 40)).foregroundColor(.gray)
                        Text("No Trips Found").font(.headline)
                        Text("Please create a trip first before adding an itinerary.").font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)
                        Spacer()
                    }.padding()
                } else if selectedTrip == nil {
                    // LAYER 1: PILIH TRIP
                    List(tripViewModel.trips) { trip in
                        Button(action: { withAnimation { selectedTrip = trip } }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(trip.title).font(.headline).foregroundColor(.primary)
                                    Text(trip.locationName).font(.subheadline).foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.gray)
                            }.padding(.vertical, 4)
                        }
                    }.listStyle(.plain)
                } else if let trip = selectedTrip {
                    // LAYER 2: PILIH HARI (Otomatis masuk ke urutan destinasi terakhir)
                    VStack(alignment: .leading) {
                        Text("Select Days for \(trip.title)").font(.subheadline.bold()).foregroundColor(.gray).padding(.horizontal, 20).padding(.top, 10)
                        
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
                                        .font(.title3).foregroundColor(selectedDays.contains(dayNum) ? Color.leapPrimary : .gray)
                                }
                                .padding(.vertical, 4)
                            }
                        }.listStyle(.plain)
                        
                        Button(action: {
                            Task {
                                isSaving = true
                                await tripViewModel.addPlaceToTrip(place: place, targetTrip: trip, selectedDays: selectedDays)
                                isSaving = false
                                dismiss() // Langsung tutup sheet setelah berhasil
                            }
                        }) {
                            HStack {
                                if isSaving { ProgressView().tint(.white) }
                                else { Image(systemName: "checkmark") }
                                Text("Done adding to this Itinerary")
                            }
                            .font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding()
                            .background(selectedDays.isEmpty ? Color.gray : Color.leapPrimary).cornerRadius(12)
                        }
                        .disabled(selectedDays.isEmpty || isSaving).padding(.horizontal, 24).padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(selectedTrip == nil ? "Choose Itinerary" : "Select Target Days")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if let _ = selectedTrip { Button("Back") { withAnimation { selectedTrip = nil } } }
                    else { Button("Cancel") { dismiss() } }
                }
            }
            // REVISI: Ganti .onAppear menjadi .task agar lebih sinkron dan aman untuk pemuatan data
            .task {
                tripViewModel.loadUserTrips()
            }
        }
    }
    
    private func calculateTotalDays(start: Date, end: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: start), to: Calendar.current.startOfDay(for: end))
        return max(1, (components.day ?? 0) + 1)
    }
}
