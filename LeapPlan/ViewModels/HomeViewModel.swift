import Foundation
import Combine
import FirebaseAuth

@MainActor
class HomeViewModel: ObservableObject {
    @Published var trendingPlaces: [FSQPlace] = []
    @Published var recentTrip: Trip? = nil
    @Published var recentTripPlacesCount: Int = 0
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let fourSquareService: FourSquareServiceProtocol
    private let firestoreRepo: FirestoreRepositoryProtocol
    private let authService: AuthServiceProtocol
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    // Flag ini krusial biar nggak narik data berkali-kali
    private var hasInitialized = false
    
    init(fourSquareService: FourSquareServiceProtocol? = nil,
         firestoreRepo: FirestoreRepositoryProtocol? = nil,
         authService: AuthServiceProtocol? = nil) {
        
        self.fourSquareService = fourSquareService ?? FourSquareService()
        self.firestoreRepo = firestoreRepo ?? FirestoreRepository()
        self.authService = authService ?? AuthService()
        
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        self.authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                guard let self = self else { return }
                // Kalau user log out, reset recent trip
                if user == nil {
                    self.recentTrip = nil
                }
                // Refresh data dashboard saat status auth berubah
                await self.loadDashboardData()
            }
        }
    }
    
    deinit {
        if let handle = authStateHandle { Auth.auth().removeStateDidChangeListener(handle) }
    }
    
    // Fungsi Utama yang dipanggil UI
    func loadDashboardData() async {
        // Mencegah loading dobel kalau lagi proses
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Tarik Data Destinasi (Hanya tarik jika trendingPlaces masih kosong)
            if trendingPlaces.isEmpty {
                self.trendingPlaces = try await fourSquareService.fetchTrendingPlaces(city: "Surabaya")
            }
            
            // 2. Tarik Data Trip (Hanya jika user login)
            if let userID = authService.getCurrentUserID() {
                let allTrips = try await firestoreRepo.fetchTrips(forUserID: userID)
                let activeTrips = allTrips.filter { $0.status == .upcoming || $0.status == .ongoing }
                self.recentTrip = activeTrips.sorted(by: { $0.startDate < $1.startDate }).first
                
                if let trip = self.recentTrip, let tripID = trip.id {
                    let dayPlans = try await firestoreRepo.fetchDayPlans(forTripID: tripID, userID: userID)
                    self.recentTripPlacesCount = dayPlans.reduce(0) { $0 + $1.destinations.count }
                } else {
                    self.recentTripPlacesCount = 0
                }
                
            } else {
                self.recentTrip = nil
                self.recentTripPlacesCount = 0
            }
            
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
