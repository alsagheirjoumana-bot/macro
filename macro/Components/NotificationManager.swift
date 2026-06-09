//
//  NotificationManager.swift
//  macro
//
//  Created by May Alqunaytir on 09/06/2026.
//


import Foundation
import UserNotifications
import CoreLocation

final class NotificationManager: NSObject, CLLocationManagerDelegate {

    static let shared = NotificationManager()

    private let locationManager = CLLocationManager()

    private override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            print("Notifications:", granted)

            if let error {
                print(error.localizedDescription)
            }
        }
    }

    func requestLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    func scheduleTimeReminder() {

        let content = UNMutableNotificationContent()
        content.title = "Places Reminder"
        content.body = "Don't forget to check your saved places."
        content.sound = .default

        var date = DateComponents()
        date.hour = 20
        date.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: date,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "daily-place-reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func placeWasSaved(_ place: SavedPlace) {

        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            print("Location notification skipped. Always location is not allowed.")
            return
        }

        scheduleLocationReminder(for: place)
    }

    func placeWasDeleted(_ place: SavedPlace) {

        let identifier = notificationID(for: place)

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [identifier]
            )

        print("Removed notification for:", place.name)
    }

    private func scheduleLocationReminder(for place: SavedPlace) {

        guard
            let latitude = place.latitude,
            let longitude = place.longitude
        else {
            print("No coordinates for:", place.name)
            return
        }

        let center = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )

        let region = CLCircularRegion(
            center: center,
            radius: 3000,
            identifier: notificationID(for: place)
        )

        region.notifyOnEntry = true
        region.notifyOnExit = false

        let content = UNMutableNotificationContent()

        if place.isVisited {
            content.title = "📍 Welcome back!"
            content.body = "You're near \(place.name) again."
        } else {
            content.title = "⭐ Wishlist Reminder"
            content.body = "You're near \(place.name)!"
        }

        content.sound = .default

        let trigger = UNLocationNotificationTrigger(
            region: region,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: notificationID(for: place),
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Location notification error:", error.localizedDescription)
            } else {
                print("Scheduled location notification for:", place.name)
            }
        }
    }

    private func notificationID(for place: SavedPlace) -> String {
        "place-\(place.id.uuidString)"
    }
}
