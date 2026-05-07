import CoreLocation
import Foundation

// MARK: - Protocol

protocol LocationServiceProtocol {
    func requestPermission() async -> Bool
    func currentLocation() async -> HabitLocation?
}

// MARK: - Service

@MainActor
final class LocationService: NSObject, LocationServiceProtocol {
    static let shared = LocationService()

    private let manager = CLLocationManager()
    private var awaitingPermission: CheckedContinuation<Bool, Never>?
    private var awaitingCoordinates: CheckedContinuation<HabitLocation?, Never>?

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // MARK: - Actions

    func requestPermission() async -> Bool {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                awaitingPermission = continuation
                manager.requestWhenInUseAuthorization()
            }
        @unknown default:
            return false
        }
    }

    func currentLocation() async -> HabitLocation? {
        let permitted = await requestPermission()
        guard permitted else { return nil }

        return await withCheckedContinuation { continuation in
            awaitingCoordinates = continuation
            manager.requestLocation()
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let coord = locations.first?.coordinate else { return }
        let result = HabitLocation(lat: coord.latitude, lng: coord.longitude)
        Task { @MainActor in
            awaitingCoordinates?.resume(returning: result)
            awaitingCoordinates = nil
        }
    }

    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("LocationService didFail: \(error.localizedDescription)")
        Task { @MainActor in
            awaitingCoordinates?.resume(returning: nil)
            awaitingCoordinates = nil
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            guard manager.authorizationStatus != .notDetermined else { return }
            let granted = manager.authorizationStatus == .authorizedWhenInUse
                || manager.authorizationStatus == .authorizedAlways
            awaitingPermission?.resume(returning: granted)
            awaitingPermission = nil
        }
    }
}
