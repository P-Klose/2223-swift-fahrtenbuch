//
//  ViewModel.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 20.03.23.
//

import Foundation
import UserNotifications
import CoreLocation


class ViewModel: ObservableObject {
    
    func checkForPremission(){
        let notifacationCenter = UNUserNotificationCenter.current()
        notifacationCenter.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispachNotification()
            case .denied:
                return
            case .notDetermined:
                notifacationCenter.requestAuthorization(options: [.alert, .sound]) { didAllow, error in
                    if didAllow {
                        self.dispachNotification()
                    }
                }
            default:
                return
            }
        }
    }
    
    
    func dispachNotification() {
        let identifier = "my-fahrtenbuch-notification"
        let title = "Let's go on a drive!"
        let body = "..."
        let hour = 12
        let minute = 38
        let isDaily = true
        
        let notifacationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.body = body
        content.title = title
        content.sound = .default
        
        let calender = Calendar.current
        var dateComponent = DateComponents(calendar: calender, timeZone: .current)
        dateComponent.minute = minute
        dateComponent.hour = hour
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: isDaily)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notifacationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notifacationCenter.add(request)
    }
}
