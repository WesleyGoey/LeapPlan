//
//  CreateManualTripView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//


import SwiftUI

struct CreateManualTripView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripViewModel // TERHUBUNG LANGSUNG KE TRIPVIEWMODEL
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Trip Destination")) {
                    TextField("Enter City (e.g., Surabaya)", text: $viewModel.destinationForm)
                }
                
                Section(header: Text("Travel Dates")) {
                    DatePicker("Start Date", selection: $viewModel.startDateForm, displayedComponents: .date)
                    DatePicker("End Date", selection: $viewModel.endDateForm, displayedComponents: .date)
                }
            }
            .navigationTitle("Create Manual Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Create") {
                            Task {
                                isSaving = true
                                do {
                                    _ = try await viewModel.createManualTrip()
                                    dismiss()
                                } catch { print("Gagal: \(error)") }
                                isSaving = false
                            }
                        }
                        .bold()
                        .disabled(viewModel.destinationForm.isEmpty)
                    }
                }
            }
        }
    }
}
