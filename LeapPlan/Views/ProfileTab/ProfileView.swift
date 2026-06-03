//
//  ProfileView.swift
//  LeapPlan
//
//  Created by student on 03/06/26.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isShowingAuthSheet = false
    @State private var isShowingEditSheet = false
    @State private var showingComingSoonAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F9F9F9").ignoresSafeArea()
                
                VStack {
                    if viewModel.isLoading {
                        ProgressView().scaleEffect(1.5)
                    } else if let user = viewModel.currentUser {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 24) {
                                VStack(spacing: 16) {
                                    ZStack(alignment: .bottomTrailing) {
                                        if let base64String = user.profileImageUrl, let uiImage = Base64Helper.decode(base64String) {
                                            Image(uiImage: uiImage).resizable().scaledToFill()
                                                .frame(width: 110, height: 110).clipShape(Circle())
                                                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                                        } else {
                                            Circle().fill(Color.leapPrimary.opacity(0.2))
                                                .frame(width: 110, height: 110)
                                                .overlay(Text(String(user.fullName.prefix(1)).uppercased()).font(.system(size: 45, weight: .bold)).foregroundColor(.leapPrimary))
                                        }
                                        
                                        Circle().fill(Color(hex: "#50B498")).frame(width: 22, height: 22)
                                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                                            .offset(x: -4, y: -4)
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text(user.fullName).font(.title2).fontWeight(.bold).foregroundColor(.leapSecondary)
                                        Text(user.email).font(.subheadline).foregroundColor(.gray)
                                    }
                                    
                                    Button(action: {
                                        viewModel.populateEditForm()
                                        isShowingEditSheet = true
                                    }) {
                                        Text("Edit Profile")
                                            .font(.subheadline.bold())
                                            .foregroundColor(.leapPrimary)
                                            .padding(.horizontal, 32)
                                            .padding(.vertical, 10)
                                            .overlay(Capsule().stroke(Color.leapPrimary, lineWidth: 1.5))
                                    }
                                }
                                .padding(.top, 30)
                                
                                HStack(spacing: 20) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "airplane")
                                            .font(.title2)
                                            .foregroundColor(.leapPrimary)
                                        Text("\(viewModel.totalTripsCount)")
                                            .font(.title).fontWeight(.bold).foregroundColor(.leapSecondary)
                                        Text("Total Trips")
                                            .font(.caption).foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                                    
                                    VStack(spacing: 8) {
                                        Image(systemName: "calendar.badge.clock")
                                            .font(.title2)
                                            .foregroundColor(.leapHighlight)
                                        Text("\(viewModel.upcomingTripsCount)")
                                            .font(.title).fontWeight(.bold).foregroundColor(.leapSecondary)
                                        Text("Upcoming")
                                            .font(.caption).foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 10)
                                
                                VStack(spacing: 0) {
                                    Button(action: {
                                        viewModel.logout()
                                    }) {
                                        HStack(spacing: 16) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.1)).frame(width: 40, height: 40)
                                                Image(systemName: "rectangle.portrait.and.arrow.right").foregroundColor(.red)
                                            }
                                            Text("Log Out").font(.headline).fontWeight(.bold).foregroundColor(.red)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(12)
                                .padding(.horizontal, 24)
                                .padding(.top, 10)
                                
                                Spacer(minLength: 30)
                                
                                Text("LeapPlan v1.0.0 · Made with ❤️")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 40)
                            }
                        }
                    } else {
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: "person.crop.circle.badge.questionmark").font(.system(size: 80)).foregroundColor(.gray.opacity(0.5))
                            Text("You're not logged in").font(.title2.bold()).foregroundColor(.leapSecondary)
                            Text("Login or create an account to start planning your perfect trip, saving itineraries, and more.").font(.body).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal, 40)
                            
                            Button(action: {
                                viewModel.clearAuthForm()
                                isShowingAuthSheet = true
                            }) {
                                Text("Login / Register").fontWeight(.semibold).frame(maxWidth: .infinity).padding().background(Color.leapPrimary).foregroundColor(.white).cornerRadius(16).shadow(color: Color.leapPrimary.opacity(0.3), radius: 5, y: 2)
                            }
                            .padding(.horizontal, 40).padding(.top, 20)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(viewModel.currentUser != nil ? "" : "Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(viewModel.currentUser != nil)
            .onAppear { viewModel.loadProfile() }
            .sheet(isPresented: $isShowingAuthSheet) {
                LoginRegisterSheetView(viewModel: viewModel)
            }
            .sheet(isPresented: $isShowingEditSheet) {
                EditProfileView(viewModel: viewModel)
            }
            .alert("Coming Soon! 🚀", isPresented: $showingComingSoonAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This feature is currently under development.")
            }
        }
    }
}

struct LoginRegisterSheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var isLoginMode = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Picker("Mode", selection: $isLoginMode) {
                    Text("Login").tag(true)
                    Text("Register").tag(false)
                }.pickerStyle(.segmented).padding(.horizontal)
                
                if let error = viewModel.errorMessage {
                    Text(error).font(.caption).foregroundColor(.white).padding().background(Color.leapHighlight.opacity(0.9)).cornerRadius(8).padding(.horizontal)
                }
                
                VStack(spacing: 16) {
                    if !isLoginMode {
                        TextField("Full Name", text: $viewModel.authFullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    TextField("Email", text: $viewModel.authEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("Password", text: $viewModel.authPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }.padding(.horizontal)
                
                Button(action: {
                    Task {
                        let success = isLoginMode ? await viewModel.login() : await viewModel.register()
                        if success { dismiss() }
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(isLoginMode ? "Log In" : "Create Account").fontWeight(.bold)
                    }
                }
                .frame(maxWidth: .infinity).padding().background(Color.leapPrimary).foregroundColor(.white).cornerRadius(12).padding(.horizontal).shadow(color: Color.leapPrimary.opacity(0.3), radius: 5, y: 2)
                .disabled(viewModel.authEmail.isEmpty || viewModel.authPassword.isEmpty || (!isLoginMode && viewModel.authFullName.isEmpty))
                
                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle(isLoginMode ? "Welcome Back" : "Join LeapPlan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }.foregroundColor(.leapSecondary)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
