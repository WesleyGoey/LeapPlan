//
//  ProfileView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//


import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isShowingAuthSheet = false
    @State private var isShowingEditSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView().scaleEffect(1.5)
                } else if viewModel.isLoggedIn {
                    if let user = viewModel.currentUser {
                        VStack(spacing: 24) {
                            // MENGGUNAKAN BASE64 HELPER
                            if let base64String = user.profileImageUrl,
                               let uiImage = Base64Helper.decode(base64String) {
                                Image(uiImage: uiImage).resizable().scaledToFill()
                                    .frame(width: 120, height: 120).clipShape(Circle())
                                    .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                            } else {
                                Circle().fill(Color.leapPrimary.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(Text(String(user.fullName.prefix(1).uppercased())).font(.system(size: 50, weight: .bold)).foregroundColor(.leapPrimary))
                            }
                            
                            VStack(spacing: 8) {
                                Text(user.fullName).font(.title2.bold()).foregroundColor(.leapSecondary)
                                Text(user.email).font(.subheadline).foregroundColor(.gray)
                            }
                            
                            Button(action: {
                                viewModel.populateEditForm()
                                isShowingEditSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit Profile")
                                }.fontWeight(.semibold).frame(width: 200).padding().background(Color.leapPrimary).foregroundColor(.white).cornerRadius(30).shadow(color: Color.leapPrimary.opacity(0.3), radius: 5, y: 2)
                            }
                            
                            Spacer()
                            
                            Button(action: { viewModel.logout() }) {
                                Text("Log Out").fontWeight(.semibold).foregroundColor(.leapHighlight)
                            }.padding(.bottom, 30)
                        }.padding(.top, 40)
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
            .navigationTitle("Profile")
            .onAppear { viewModel.loadProfile() }
            .sheet(isPresented: $isShowingAuthSheet) {
                LoginRegisterSheetView(viewModel: viewModel)
            }
            .sheet(isPresented: $isShowingEditSheet) {
                EditProfileView(viewModel: viewModel)
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
