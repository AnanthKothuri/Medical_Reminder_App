//
//  NotificationsManager.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/16/22.
//

import Foundation
import UserNotifications
import UIKit

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationHandler()
    
    // handle notification when app is in background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // pushing notification if it's not a background notification
        if response.notification.request.identifier != "background.notification" {
            let notiName = Notification.Name(response.notification.request.identifier)
            
            // if this is a med notification
            if response.notification.request.identifier.contains("med.notification") {
                // have voice assistant verbalize the medication
                let medDict = response.notification.request.content.userInfo
                print("This is the medDict: \(medDict)")
                
                // setting dosage amounts in message
                var amount = ""
                if medDict["medDosage"] != nil && medDict["medDosageUnit"] != nil {
                    amount = "\(medDict["medDosage"]!) \(medDict["medDosageUnit"]!) of "
                }
                
                // setting notes in message
                var notes = ""
                if medDict["medNotes"] != nil {
                    notes = "Notes. \(medDict["medNotes"]!)"
                }
                
                let text = "This is your reminder to take \(amount) \(medDict["medName"]!). \(notes)"
                
                SpeechManager.shared.speak(text: text)
            }
            
            NotificationCenter.default.post(name: notiName, object: response.notification.request.content)
            
        } else {
            // this IS the background notification, don't push notification
            // update the notifications for today
            BackgroundManager.shared.mainRefresh()
        }
        
        // persist notification if its meant to repeat
        
        
        completionHandler()
    }
    
    // handle notification when app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // pushing notification if it's not a background notification
        if notification.request.identifier != "background.notification" {
            
            // if this is a med notification
            if notification.request.identifier.contains("med.notification") {
                // have voice assistant verbalize the medication
                let medDict = notification.request.content.userInfo
                print("This is the medDict: \(medDict)")
                
                // setting dosage amounts in message
                var amount = ""
                if medDict["medDosage"] != nil && medDict["medDosageUnit"] != nil {
                    amount = "\(medDict["medDosage"]!) \(medDict["medDosageUnit"]!) of "
                }
                
                // setting notes in message
                var notes = ""
                if medDict["medNotes"] != nil && medDict["medNotes"] as! String != "" {
                    notes = "Notes. \(medDict["medNotes"]!)"
                }
                
                let text = "This is your reminder to take \(amount) \(medDict["medName"]!). \(notes)"
                
                SpeechManager.shared.speak(text: text)
            }
            
            completionHandler([.alert, .sound, .badge])
            
        } else {
            // this IS the background notification, don't push notification
            // update the notifications for today
            BackgroundManager.shared.mainRefresh()
        }
    }
}


// getting permission from settings
extension NotificationHandler  {
    func requestPermission(_ delegate : UNUserNotificationCenterDelegate? = nil ,
        onDeny handler :  (()-> Void)? = nil){  // an optional onDeny handler is better here,
                                                // so there is an option not to provide one, have one only when needed
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings(completionHandler: { settings in
        
            if settings.authorizationStatus == .denied {
                if let handler = handler {
                    handler()
                }
                return
            }
            
            if settings.authorizationStatus != .authorized  {
                center.requestAuthorization(options: [.alert, .sound, .badge]) {
                    _ , error in
                    
                    if let error = error {
                        print("error handling \(error)")
                    }
                }
            }
            
        })
        center.delegate = delegate ?? self
    }
}


// adding and removing notifications
extension NotificationHandler {
    
    // adding repeatable notification starting from the exact moment
    func addNotification(med: Med, intervalInSeconds: Double,
                         sound : UNNotificationSound = UNNotificationSound.default) {
        let id = "\(med.medName).med.notification"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalInSeconds, repeats: true)
        
        let content = UNMutableNotificationContent()
        if med.medDosage != nil && med.medDosageUnit != nil {
            content.title = "Take \(med.medDosage!) \(med.medDosageUnit!) of \(med.medName)"
        } else {
            content.title = "Take \(med.medName)"
        }
        
        content.subtitle = "From \(med.medStartDate.formatted(date: .abbreviated, time: .omitted)) to "
                            + "\(med.medEndDate.formatted(date: .abbreviated, time: .omitted))"
        content.userInfo = med.getDictionary()
        content.sound = sound

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    // adding notification at a given time
    func addNotification(med: Med, date: Date,
                         sound : UNNotificationSound = UNNotificationSound.default) {
        
        let id = "\(med.medName).\(date.formatted(date: .omitted, time: .standard)).med.notification"
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        if med.medDosage != nil && med.medDosageUnit != nil {
            content.subtitle = "Take \(med.medDosage!) \(med.medDosageUnit!). Notes: \(med.medNotes ?? "None")."
        } else {
            content.subtitle = "Notes: \(med.medNotes ?? "None")."
        }
        
        content.title = "\(med.medName) Medication Reminder"
        content.userInfo = med.getDictionary()
        content.sound = sound

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    // adding notification at a given time and message
    func addNotification(title: String, subtitle: String, date: Date,
                         sound : UNNotificationSound = UNNotificationSound.default) {
        let id = "message.notification"
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.sound = sound

        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // adding backgroundNotification
    func addBackgroundNotification(date: Date) {
        let id = "background.notification"
        
        let dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "Background Notification"
        content.subtitle = "Should not be seen"
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }

    func removeNotifications(_ ids : [String]){
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

}

// getting all med notifications that are currently pending
// return the name and dates of each notification
extension NotificationHandler {
    func getPendingMedNotifications() async -> [MedItem] {
        var bigList : [MedItem] = []
  
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()
        
        for request in requests {
            // this is a med notification
            var id = request.identifier
            
            if id.contains(".med.notification") {
                
                // get rid of ".notification" in name
                var firstNdx = id.lastIndex(of: ".")!
                id = String(id[id.startIndex..<firstNdx])
                
                // get rid of ".med" in name
                firstNdx = id.lastIndex(of: ".")!
                id = String(id[id.startIndex..<firstNdx])
                
                // getting the date of this medication reminder
                firstNdx = id.lastIndex(of: ".")!
                let ndx = id.index(after: firstNdx)
                let dateString = String(id[ndx...])
                
                // get rid of the dateString in name
                id = String(id[id.startIndex..<firstNdx])
                
                // simplify datestring from HH:mm:ss to HH:mm
                
                let name = id
                
                bigList.append(MedItem(name: name, date: dateString))
            }
        }
        
        
        return bigList
    }
    
    func removeCurrentMedNotifications() {

        Task {
            let list = await getPendingMedNotifications()
            
            var removeList : [String] = []
            
            for med in list {
                let id = "\(med.name).\(med.date).med.notification"
                removeList.append(id)
            }
            
            
            await UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: removeList)
        }
    }
}
