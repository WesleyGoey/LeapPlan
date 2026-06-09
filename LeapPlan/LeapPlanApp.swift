//
//  LeapPlanApp.swift
//  LeapPlan
//
//  Created by Wesley Goey on 28/05/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    // Start WatchConnectivity listener
    Task { @MainActor in
        IOSWatchSessionManager.shared.startSession()
    }
    
    return true
  }
}

@main
struct LeapPlanApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
        // Cukup panggil ContentView, jangan bungkus dengan NavigationView lagi
        ContentView()
    }
  }
}
