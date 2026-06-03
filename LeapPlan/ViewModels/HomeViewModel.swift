import Foundation
import Combine
import FirebaseAuth 

@MainActor
class HomeViewModel: ObservableObject {
    @Published var trendingPlaces: [FSQPlace] = []
    @Published var recentTrip: Trip? = nil
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let fourSquareService: FourSquareServiceProtocol
    private let firestoreRepo: FirestoreRepositoryProtocol
    private let authService: AuthServiceProtocol
    
    // Variabel untuk menyimpan listener agar tidak memory leak
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    init(fourSquareService: FourSquareServiceProtocol? = nil,
         firestoreRepo: FirestoreRepositoryProtocol? = nil,
         authService: AuthServiceProtocol? = nil) {
        self.fourSquareService = fourSquareService ?? FourSquareService()
        self.firestoreRepo = firestoreRepo ?? FirestoreRepository()
        self.authService = authService ?? AuthService()
        
        // PASANG LISTENER: Bekerja di background untuk memantau status login
        self.authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self = self else { return }
                if user == nil {
                    // Jika Logout: Langsung hapus trip dari layar Home
                    self.recentTrip = nil
                    self.loadTrendingPlacesOnly()
                } else {
                    // Jika Login: Tarik data terbaru
                    self.loadDashboardData()
                }
            }
        }
    }
    
    deinit {
        // Membersihkan listener saat aplikasi ditutup
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func loadDashboardData() {
        // Ambil ID User; jika belum login (Guest), ambil trip kosong
        guard let userID = authService.getCurrentUserID() else {
            self.recentTrip = nil
            self.loadTrendingPlacesOnly()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 1. Tarik Data Destinasi (API)
                let places = try await fourSquareService.fetchTrendingPlaces(city: "Surabaya")
                self.trendingPlaces = places
                
                // 2. Tarik Data Trip (Firebase)
                let allTrips = try await firestoreRepo.fetchTrips(forUserID: userID)
                let activeTrips = allTrips.filter { $0.status == .upcoming || $0.status == .ongoing }
                self.recentTrip = activeTrips.sorted(by: { $0.startDate < $1.startDate }).first
                
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func loadTrendingPlacesOnly() {
        Task {
            do {
                self.trendingPlaces = try await fourSquareService.fetchTrendingPlaces(city: "Surabaya")
            } catch {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
