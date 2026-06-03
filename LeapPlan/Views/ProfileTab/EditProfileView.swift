//
//  EditProfileView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedUIImage: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile Picture")) {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            
                            // MENGGUNAKAN BASE64 HELPER
                            if let selectedUIImage {
                                Image(uiImage: selectedUIImage).resizable().scaledToFill().frame(width: 100, height: 100).clipShape(Circle())
                            } else if let base64 = viewModel.editProfileImageBase64, let uiImage = Base64Helper.decode(base64) {
                                Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 100, height: 100).clipShape(Circle())
                            } else {
                                Circle().fill(Color.gray.opacity(0.2)).frame(width: 100, height: 100).overlay(Image(systemName: "person.fill").font(.largeTitle).foregroundColor(.gray))
                            }
                            
                            HStack(spacing: 20) {
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                                    Text("Change Photo").font(.subheadline).foregroundColor(.leapPrimary)
                                }
                                
                                if viewModel.editProfileImageBase64 != nil || selectedUIImage != nil {
                                    Button(role: .destructive, action: {
                                        withAnimation {
                                            selectedUIImage = nil
                                            viewModel.editProfileImageBase64 = nil
                                            selectedPhotoItem = nil
                                        }
                                    }) {
                                        Image(systemName: "trash").font(.subheadline).foregroundColor(.leapHighlight)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Personal Info")) {
                    TextField("Full Name", text: $viewModel.editFullName)
                    TextField("Email", text: $viewModel.editEmail).keyboardType(.emailAddress).autocapitalization(.none)
                }
                
                Section(header: Text("Security"), footer: Text("Leave new password empty if you don't want to change it. Current password is required to save email/password changes.")) {
                    SecureField("New Password (Optional)", text: $viewModel.editPassword)
                    SecureField("Current Password (Required for changes)", text: $viewModel.currentPassword)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundColor(.leapSecondary) }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                let success = await viewModel.saveEditedProfile(selectedImage: selectedUIImage)
                                if success { dismiss() }
                            }
                        }.bold().foregroundColor(.leapPrimary)
                    }
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                        selectedUIImage = img
                    }
                }
            }
        }
    }
}
