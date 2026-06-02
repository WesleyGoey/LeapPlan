//
//  CreateManualTripView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import SwiftUI

struct CreateManualTripView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var location: String = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
    @State private var isSaving = false
    
    var onSave: ((String, Date, Date) async -> Void)?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Trip Destination")) {
                    TextField("Enter City (e.g., Surabaya)", text: $location)
                }
                
                Section(header: Text("Travel Dates")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
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
                                await onSave?(location, startDate, endDate)
                            }
                        }
                        .bold()
                        .disabled(location.isEmpty)
                    }
                }
            }
        }
    }
}
