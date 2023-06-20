//
//  ViewModel.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 20.03.23.
//

import Foundation
import UserNotifications
import CoreLocation


class HomeViewModel: ObservableObject{
    var notificationsAllowed: Bool?
    
    func checkForPremission(){
        let notifacationCenter = UNUserNotificationCenter.current()
        notifacationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.notificationsAllowed = true;
            case .denied:
                self.notificationsAllowed = false;
                return
            case .notDetermined:
                notifacationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.notificationsAllowed = true;
                    }
                }
            default:
                return
            }
        }
    }
    
    
    func dispachNotification(for _vehicle: Vehicle, forValues: [Int]) {
        let identifier = _vehicle.getFullName()
        let title = "Pickerl Erinnerung"
        let body = "Bei ihrem \(_vehicle.make) \(_vehicle.model) mit dem Kennzeichen \(_vehicle.numberplate) ist nun der Zeitraum offen die §57a Überprüfung zu vollziehen."
        let isDaily = false
        
        let notifacationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.body = body
        content.title = title
        content.sound = .default
        
        let calender = Calendar.current
        var dateComponent = DateComponents(calendar: calender, timeZone: .current)
        dateComponent.year = forValues[2]
        dateComponent.month = forValues[0]
        dateComponent.day = 1
        dateComponent.minute = 0
        dateComponent.hour = 8
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notifacationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notifacationCenter.add(request)
    }
}
