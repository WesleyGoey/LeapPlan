//
//  CreateManualTripView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import SwiftUI

struct CreateManualTripView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripViewModel
    @State private var isSaving = false
    @FocusState private var isDestinationFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(hex: "#F9F9F9").ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: - Masukkan ini ke dalam VStack ScrollView Anda
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TRIP NAME (OPTIONAL)").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                            TextField("e.g., Summer Holiday", text: $viewModel.tripNameForm)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                        }
                        .padding(.horizontal, 20)
                        
                        // SECTION DESTINATION
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESTINATION").font(.caption).fontWeight(.bold)
                                .foregroundColor(.gray)
                            VStack(spacing: 0) {
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(Color(hex: "#50B498"))
                                    TextField(
                                        "Enter City (e.g., Surabaya)",
                                        text: $viewModel.destinationForm
                                    )
                                    .focused($isDestinationFocused)
                                    .autocorrectionDisabled()
                                }
                                .padding().background(Color.white).cornerRadius(
                                    16
                                ).shadow(
                                    color: .black.opacity(0.05),
                                    radius: 5,
                                    y: 2
                                )

                                // DROPDOWN AUTOCOMPLETE (Sama seperti Generate)
                                if isDestinationFocused
                                    && !viewModel.autocompleteResults.isEmpty
                                {
                                    VStack(spacing: 0) {
                                        ForEach(
                                            viewModel.autocompleteResults,
                                            id: \.self
                                        ) { placeName in
                                            Button {
                                                viewModel.destinationForm =
                                                    placeName
                                                isDestinationFocused = false
                                                UIApplication.shared.sendAction(
                                                    #selector(
                                                        UIResponder
                                                            .resignFirstResponder
                                                    ),
                                                    to: nil,
                                                    from: nil,
                                                    for: nil
                                                )
                                            } label: {
                                                HStack(spacing: 16) {
                                                    Image(
                                                        systemName:
                                                            "mappin.circle.fill"
                                                    ).font(.title2)
                                                        .foregroundColor(
                                                            .gray.opacity(0.8)
                                                        )
                                                    Text(placeName).font(.body)
                                                        .foregroundColor(
                                                            .primary
                                                        )
                                                    Spacer()
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 14)
                                                .background(Color.white)
                                            }
                                            if placeName
                                                != viewModel.autocompleteResults
                                                .last
                                            {
                                                Divider().padding(.leading, 50)
                                            }
                                        }
                                    }
                                    .background(Color.white).cornerRadius(16)
                                    .shadow(
                                        color: .black.opacity(0.15),
                                        radius: 10,
                                        y: 5
                                    ).padding(.top, 8)
                                }
                            }
                            .zIndex(10)
                        }
                        .padding(.horizontal, 20).padding(.top, 20)

                        // SECTION DATES
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TRAVEL DATES").font(.caption).fontWeight(
                                .bold
                            ).foregroundColor(.gray)
                            VStack(spacing: 0) {
                                DatePicker(
                                    "Start Date",
                                    selection: $viewModel.startDateForm,
                                    displayedComponents: .date
                                ).padding()
                                Divider().padding(.horizontal)
                                DatePicker(
                                    "End Date",
                                    selection: $viewModel.endDateForm,
                                    displayedComponents: .date
                                ).padding()
                            }
                            .background(Color.white).cornerRadius(16).shadow(
                                color: .black.opacity(0.05),
                                radius: 5,
                                y: 2
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                }

                // Tombol Create
                Button {
                    Task {
                        isSaving = true
                        do {
                            _ = try await viewModel.createManualTrip()
                            dismiss()
                        } catch { print("Gagal: \(error)") }
                        isSaving = false
                    }
                } label: {
                    Text(isSaving ? "Creating..." : "Create Trip").font(
                        .headline
                    )
                    .foregroundColor(.white).frame(maxWidth: .infinity).padding(
                        .vertical,
                        18
                    )
                    .background(
                        viewModel.destinationForm.isEmpty
                            ? Color.gray : Color.leapPrimary
                    )
                    .cornerRadius(16)
                }
                .padding(20)
                .disabled(viewModel.destinationForm.isEmpty || isSaving)
            }
            .navigationTitle("Create Manual Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onDisappear {
                viewModel.resetForm()
            }
        }
    }
}
