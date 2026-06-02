//
//  PlaceNotificationManager.swift
//  macro
//
//  Created by Joumana Alsagheir on 02/06/2026.
//

import Foundation
import CoreLocation
import UserNotifications

final class PlaceNotificationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = PlaceNotificationManager()
    
    private let manager = CLLocationManager()
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermissions() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }
    
    func monitorPlaces(_ places: [SavedPlace]) {
        
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            return
        }
        
        for place in places {
            
            guard let lat = place.latitude,
                  let lon = place.longitude else {
                continue
            }
            
            let identifier = "place-\(place.id.uuidString)"
            
            UserDefaults.standard.set(
                place.name,
                forKey: identifier
            )
            
            let alreadyMonitoring = manager.monitoredRegions.contains {
                $0.identifier == identifier
            }
            
            if alreadyMonitoring {
                continue
            }
            
            let region = CLCircularRegion(
                center: CLLocationCoordinate2D(
                    latitude: lat,
                    longitude: lon
                ),
                radius: 200,
                identifier: identifier
            )
            
            region.notifyOnEntry = true
            region.notifyOnExit = false
            
            manager.startMonitoring(for: region)
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {
        let placeName = UserDefaults.standard.string(
            forKey: region.identifier
        ) ?? "a saved place"
        
        let content = UNMutableNotificationContent()
        content.title = "You're close to \(placeName)"
        content.body = "A place you wanted to visit is nearby. Do you want to try it?"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
