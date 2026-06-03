//
//  TripDetailView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//


import MapKit
import PhotosUI
import SwiftUI


struct TripDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TripDestinationViewModel // NAMA BARU

    @State private var position: MapCameraPosition = .automatic
    @State private var isShowingEditSheet = false
    @State private var isShowingFABMenu = false
    @State private var isShowingAddPlaceSheet = false
    @State private var selectedDestinationToEdit: TripDestination? = nil

    init(trip: Trip) {
        _viewModel = StateObject(wrappedValue: TripDestinationViewModel(trip: trip))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // HEADER PETA
                ZStack(alignment: .topLeading) {
                    Map(position: $position) {
                        if let dayPlan = viewModel.currentDayPlan {
                            let validDestinations = dayPlan.destinations.filter { $0.latitude != 0.0 && $0.longitude != 0.0 }
                            let coordinates = validDestinations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                            
                            MapPolyline(coordinates: coordinates).stroke(Color.leapPrimary, style: StrokeStyle(lineWidth: 3, dash: [6, 6]))
                            
                            ForEach(Array(validDestinations.enumerated()), id: \.element.id) { index, dest in
                                Annotation(dest.name, coordinate: CLLocationCoordinate2D(latitude: dest.latitude, longitude: dest.longitude)) {
                                    ZStack {
                                        Circle().fill(dest.category == "Tempat Makan" ? Color.pink : Color.leapPrimary).frame(width: 24, height: 24)
                                        Circle().fill(Color.white).frame(width: 10, height: 10)
                                    }.shadow(radius: 3)
                                }
                            }
                        }
                    }.frame(height: 280)

                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "arrow.left").font(.system(size: 20, weight: .semibold)).foregroundColor(.black).padding(12).background(Color.white).clipShape(Circle()).shadow(radius: 5)
                        }
                        Spacer()
                        Text("\(viewModel.trip.locationName) 📍").font(.subheadline.bold()).padding(.horizontal, 20).padding(.vertical, 10).background(Color.white).clipShape(Capsule()).shadow(radius: 5)
                        Spacer()
                        Button { isShowingEditSheet = true } label: {
                            Image(systemName: "ellipsis").font(.system(size: 20, weight: .semibold)).foregroundColor(.black).padding(12).background(Color.white).clipShape(Circle()).shadow(radius: 5)
                        }
                    }.padding(.horizontal, 20).padding(.top, 60)
                }

                // DAY SELECTOR
                if !viewModel.dayPlans.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(viewModel.dayPlans.enumerated()), id: \.element.id) { index, plan in
                                Button {
                                    withAnimation { viewModel.selectedDayIndex = index }
                                } label: {
                                    Text("Day \(plan.dayNumber)").font(.subheadline.bold()).padding(.horizontal, 20).padding(.vertical, 10)
                                        .background(viewModel.selectedDayIndex == index ? Color.leapPrimary : Color.gray.opacity(0.1))
                                        .foregroundColor(viewModel.selectedDayIndex == index ? .white : .gray).clipShape(Capsule())
                                }
                            }
                        }.padding(.horizontal, 20).padding(.vertical, 16)
                    }.background(Color.white)
                }

                // DAFTAR DESTINASI
                Group {
                    if viewModel.isLoading {
                        VStack {
                            Spacer()
                            ProgressView("Loading...").scaleEffect(1.2)
                            Spacer()
                        }
                    } else if let currentDayPlan = viewModel.currentDayPlan {
                        if currentDayPlan.destinations.isEmpty {
                            VStack {
                                Spacer()
                                Image(systemName: "mappin.and.ellipse").font(.system(size: 40)).foregroundColor(.gray.opacity(0.5)).padding(.bottom, 8)
                                Text("No destinations for this day.").font(.headline).foregroundColor(.gray)
                                Spacer()
                            }.frame(maxWidth: .infinity)
                        } else {
                            List {
                                ForEach(currentDayPlan.destinations) { dest in
                                    let time = viewModel.getFormattedTime(for: dest)
                                    let isLast = dest.id == currentDayPlan.destinations.last?.id

                                    TimelineRowView(destination: dest, time: time, isLast: isLast,
                                        onEdit: { selectedDestinationToEdit = dest },
                                        onDelete: { withAnimation { viewModel.deleteDestination(destID: dest.id) } }
                                    )
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                }.onMove { source, destination in
                                    viewModel.moveDestination(from: source, to: destination)
                                }
                                Color.clear.frame(height: 100).listRowInsets(EdgeInsets()).listRowSeparator(.hidden).listRowBackground(Color.clear)
                            }.listStyle(.plain).scrollContentBackground(.hidden)
                        }
                    }
                }.background(Color(hex: "#F9F9F9"))
            }.edgesIgnoringSafeArea(.top)

            if isShowingFABMenu {
                Color.black.opacity(0.2).ignoresSafeArea().onTapGesture {
                    withAnimation(.spring()) { isShowingFABMenu = false }
                }.zIndex(1)
            }
            detailFABMenu.zIndex(2)
        }
        .navigationBarHidden(true).onAppear { viewModel.loadDayPlans() }
        .sheet(isPresented: $isShowingEditSheet) { TripEditView(viewModel: viewModel) }
        .sheet(isPresented: $isShowingAddPlaceSheet) { AddOrEditPlaceSheetView(viewModel: viewModel, mode: .add, destinationToEdit: nil) }
        .sheet(item: $selectedDestinationToEdit) { destination in AddOrEditPlaceSheetView(viewModel: viewModel, mode: .edit, destinationToEdit: destination) }
    }

    private var detailFABMenu: some View {
        VStack(alignment: .trailing, spacing: 16) {
            if isShowingFABMenu {
                Button {
                    withAnimation { isShowingFABMenu = false }
                    isShowingAddPlaceSheet = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle").foregroundColor(.gray)
                        Text("Add Places").fontWeight(.semibold).foregroundColor(.leapSecondary)
                    }.padding(.horizontal, 20).padding(.vertical, 14).background(Color.white).clipShape(Capsule()).shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                }.transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isShowingFABMenu.toggle() }
            } label: {
                Image(systemName: isShowingFABMenu ? "xmark" : "plus").font(.system(size: 24, weight: .medium)).foregroundColor(.white).frame(width: 64, height: 64)
                    .background(isShowingFABMenu ? Color.leapSecondary : Color.leapPrimary).clipShape(Circle()).shadow(color: (isShowingFABMenu ? Color.leapSecondary : Color.leapPrimary).opacity(0.4), radius: 10, y: 5)
                    .rotationEffect(.degrees(isShowingFABMenu ? 90 : 0))
            }
        }.padding(.trailing, 24).padding(.bottom, 24)
    }
}

// Subview pendukung (Sheet Editor) menggunakan TripDestinationViewModel
struct AddOrEditPlaceSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripDestinationViewModel

    let mode: PlaceMode
    let destinationToEdit: TripDestination?

    @State private var searchQuery: String = ""
    @State private var selectedCategory = "Objek Wisata"
    @State private var stayDurationHours: Int = 2
    @State private var stayDurationMinutes: Int = 0
    @State private var selectedPlace: FSQPlace?
    @FocusState private var isSearchFocused: Bool

    init(viewModel: TripDestinationViewModel, mode: PlaceMode, destinationToEdit: TripDestination?) {
        self.viewModel = viewModel
        self.mode = mode
        self.destinationToEdit = destinationToEdit

        if mode == .edit, let dest = destinationToEdit {
            _searchQuery = State(initialValue: dest.name)
            _selectedCategory = State(initialValue: dest.category)
            _stayDurationHours = State(initialValue: dest.stayDurationMinutes / 60)
            _stayDurationMinutes = State(initialValue: dest.stayDurationMinutes % 60)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Search Location") {
                    VStack(alignment: .leading) {
                        TextField("Search in \(viewModel.trip.locationName)", text: $searchQuery)
                            .focused($isSearchFocused)
                            .onChange(of: searchQuery) { newValue in viewModel.searchPlacesAroundCity(query: newValue) }

                        if isSearchFocused && !viewModel.addSearchResults.isEmpty {
                            List(viewModel.addSearchResults, id: \.fsq_place_id) { place in
                                Button(action: {
                                    selectedPlace = place
                                    searchQuery = place.name
                                    viewModel.addSearchResults = []
                                }) { Text(place.name) }
                            }.frame(height: 150)
                        }
                    }
                }
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Objek Wisata").tag("Objek Wisata")
                        Text("Tempat Makan").tag("Tempat Makan")
                    }.pickerStyle(.segmented)
                }
                Section("Stay Duration") {
                    HStack {
                        Picker("Hours", selection: $stayDurationHours) { ForEach(0..<24) { i in Text("\(i) hrs").tag(i) } }.pickerStyle(.wheel).frame(width: 100, height: 100)
                        Picker("Minutes", selection: $stayDurationMinutes) { ForEach(0..<60) { i in Text("\(i) mins").tag(i) } }.pickerStyle(.wheel).frame(width: 100, height: 100)
                    }
                }
            }
            .navigationTitle(mode == .add ? "Add Destination" : "Edit Destination")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let totalMinutes = (stayDurationHours * 60) + stayDurationMinutes
                        viewModel.addManualDestination(name: searchQuery, category: selectedCategory, durationMinutes: totalMinutes, place: selectedPlace)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TripEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripDestinationViewModel
    
    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var coverImageUrl: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    
    init(viewModel: TripDestinationViewModel) {
        self.viewModel = viewModel
        _title = State(initialValue: viewModel.trip.title)
        _startDate = State(initialValue: viewModel.trip.startDate)
        _endDate = State(initialValue: viewModel.trip.endDate)
        _coverImageUrl = State(initialValue: viewModel.trip.coverImageUrl ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Cover Image") {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        if let selectedUIImage {
                            Image(uiImage: selectedUIImage).resizable().scaledToFill().frame(height: 150).clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            HStack {
                                Image(systemName: "photo.badge.plus").font(.title2)
                                Text("Upload image from phone")
                            }.foregroundColor(.leapPrimary).padding(.vertical, 8)
                        }
                    }.onChange(of: selectedPhotoItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                                selectedUIImage = img
                            }
                        }
                    }
                }
                Section("Trip Information") { TextField("Trip Name", text: $title) }
                Section(footer: Text("If you reduce the travel dates, the extra days from your itinerary will be permanently deleted.")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Trip").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            var finalImageUrl = coverImageUrl
                            if let selectedUIImage, let base64 = viewModel.convertImageToBase64String(image: selectedUIImage) {
                                finalImageUrl = base64
                            }
                            await viewModel.updateTripDetails(title: title, startDate: startDate, endDate: endDate, coverImageUrl: finalImageUrl)
                            dismiss()
                        }
                    }.bold()
                }
            }
        }
    }
}

// TimelineRowView sama seperti sebelumnya, biarkan tanpa diubah

struct TimelineRowView: View {
    let destination: TripDestination
    let time: String
    let isLast: Bool
    var onEdit: () -> Void
    var onDelete: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(
                        destination.category == "Tempat Makan"
                            ? Color.pink : Color.leapPrimary
                    ).frame(width: 44, height: 44).shadow(
                        color: (destination.category == "Tempat Makan"
                            ? Color.pink : Color.leapPrimary).opacity(0.4),
                        radius: 5,
                        y: 2
                    )
                    Image(
                        systemName: destination.category == "Tempat Makan"
                            ? "fork.knife" : "mappin"
                    ).foregroundColor(.white).font(
                        .system(size: 16, weight: .bold)
                    )
                }
                if !isLast {
                    Line().stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .frame(width: 2, height: 100).foregroundColor(
                            Color.gray.opacity(0.3)
                        ).padding(.top, 8)
                }
            }.padding(.leading, 20)
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(destination.name).font(.headline)
                                .foregroundColor(.leapSecondary)
                            Text(destination.category).font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(time).font(.caption.bold()).foregroundColor(
                            destination.category == "Tempat Makan"
                                ? .pink : .leapPrimary
                        ).padding(.horizontal, 10).padding(.vertical, 6)
                            .background(
                                (destination.category == "Tempat Makan"
                                    ? Color.pink : Color.leapPrimary).opacity(
                                        0.1
                                    )
                            ).clipShape(Capsule())
                        Menu {
                            Button(action: onEdit) {
                                Label("Edit Place", systemImage: "pencil")
                            }
                            Button(role: .destructive, action: onDelete) {
                                Label("Delete Place", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis").font(
                                .system(size: 18, weight: .bold)
                            ).padding(8).background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text(
                            "Stay Duration: \(destination.stayDurationMinutes / 60)h \(destination.stayDurationMinutes % 60)m"
                        )
                    }.font(.caption.bold()).foregroundColor(
                        destination.category == "Tempat Makan"
                            ? .pink : .leapPrimary
                    )
                }.padding(16).background(Color.white).cornerRadius(16).shadow(
                    color: .black.opacity(0.05),
                    radius: 5,
                    y: 2
                )
                if !isLast {
                    HStack(spacing: 6) {
                        Image(systemName: "car.fill")
                        Text(
                            "\(destination.transitTimeToNextMinutes ?? 0) mins drive"
                        )
                    }.font(.caption.bold()).foregroundColor(.leapPrimary)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Color.leapPrimary.opacity(0.1)).clipShape(
                            Capsule()
                        ).padding(.bottom, 8)
                }
            }.padding(.trailing, 20)
        }.padding(.vertical, 8)
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}
