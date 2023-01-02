//
//  BackgroundManager.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 11/22/22.
//

import Foundation
import BackgroundTasks

class BackgroundManager {
    
    static let shared = BackgroundManager()
    
    func mainRefresh() {
        print("got to background task")
        let dict = UserDefaults.standard.object(forKey: "loggedInUser")
        
        if dict == nil {
            print("empty background dictionary - no logged in user")
            return
        }
        
        
        // removing all current med notifications so that updated ones can replace them
        NotificationHandler.shared.removeCurrentMedNotifications()
        
        // converting data to a user (decoding)
        do {
            let decoder = JSONDecoder()
            let user = try decoder.decode(User.self, from: dict as! Data)
            
            
            guard user.userType == .Patient else {
//
//                // only for testing notifications
//                print("Adding dummy notification for doctors only")
//                NotificationHandler.shared.addNotification(title: "Testing Notifications", subtitle: "Should only get this if you're a doctor", date: Date(timeInterval: 5, since: .now))
                return
            }
            
            let patient = try decoder.decode(Patient.self, from: dict as! Data)

            // sets update task for the next day
            if !(user.settings.pauseNotifications) {
                // scheduling the background notification for the next day at 1AM
                let today = Calendar.current.startOfDay(for: .now)
                let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
                let one = DateComponents(hour: 1)
                let oneAM = Calendar.current.date(byAdding: one, to: tomorrow)!
                NotificationHandler.shared.addBackgroundNotification(date: oneAM)
                
                createNotificationsFromMeds(user: patient)
            }
            
        } catch {
            print("could not convert encoded data to user for background processing")
            print(dict!)
            return
        }
    }
    
    // takes the user's medications, then creates reminders for them throughout the day
    func createNotificationsFromMeds(user: Patient) {
        if user.settings.pauseNotifications {
            print("notifications are paused, returning")
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        guard var startHour = formatter.date(from: user.settings.startTimeLimit),
              var endHour = formatter.date(from: user.settings.endTimeLimit) else {
            print("Couldn't decipher start and end time limit strings")
            return
        }
        // setting it to our time zones
        startHour = startHour.addingTimeInterval(-21600)
        endHour = endHour.addingTimeInterval(-21600)

        let remindAnyTime = user.settings.remindAtAnyTime
        
        
        
        for med in user.medications {
            var medList : [Med] = []
            
            var startDate = med.medStartDate
            let endDate = med.medEndDate
            var date = Calendar.current.startOfDay(for: Date.now)
//            print(startDate.description)
//            print(endDate.description)
//            print(date.description)
            
            
            // adjust the start dates
            startDate = adjustStartDates(startDate: startDate, interval: med.medFrequency)
            print("Start Date: \(startDate.description)")
            
            
            while Calendar.current.compare(startDate, to: date, toGranularity: .day) == .orderedSame {
                // add notification, regardless of time (like 2AM, 11PM, doesn't matter)
                if remindAnyTime {
                    NotificationHandler.shared.addNotification(med: med, date: startDate)
                } else {
                    // else add time to be sorted later
                    medList.append(med)
                }
                startDate = startDate.addingTimeInterval(med.medFrequency)
            }
            
            med.medStartDate = startDate
            
            // adding reminders to a given time frame only (EX: 8AM to 5PM)
            if !remindAnyTime {
                let diff = endHour.timeIntervalSinceReferenceDate - startHour.timeIntervalSinceReferenceDate
                let interval = diff / Double(medList.count)
                
                // getting the beginning date, and beginning hour for that day
                date = Calendar.current.startOfDay(for: Date.now)
                let add = startHour.timeIntervalSince(Calendar.current.startOfDay(for: startHour))
                date = date.addingTimeInterval(add)
                date = date.addingTimeInterval(21600)
                
                for m in medList {
                    print(date)
                    if Date.now.compare(date) == .orderedAscending {
                        print("Adding notification for \(m.medName) at \(date)")
                        NotificationHandler.shared.addNotification(med: m, date: date)
                    }

                    date = date.addingTimeInterval(interval)
                }
            }
        }
        
        updateMeds(user: user)
    }
    
    // helper method for createNotificationsFromMeds
    func updateMeds(user: Patient) {
        let api = MedicineInfoAPI()
        api.loginUser(userID: user.userID, userType: "P")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        
        var newMedList : [Med] = []
        for med in user.medications {
            
            // excludes all meds that should no longer be active
            if med.medStartDate.compare(med.medEndDate) != .orderedDescending {
                newMedList.append(med)
                api.addMedicationToPatient(
                    getUserID: user.userID,
                    getUserType: "P",
                    medName: med.medName,
                    medDosage: med.medDosage ?? 0,
                    medDosageUnit: med.medDosageUnit ?? "N/A",
                    medFrequency: med.medFrequency,
                    medFrequencyString: med.medFrequencyString,
                    startDate: formatter.string(from: med.medStartDate),
                    endDate: formatter.string(from: med.medEndDate),
                    medNotes: med.medNotes)
            } else {
                // removing from database
                api.removeMedicationFromPatient(getUserID: user.userID, getUserType: "P", removeMed: med.medName)
            }
        }
        user.medications = newMedList
        
        Utils.shared.saveToUserDefaults(user: user)
    }
    
    
    func adjustStartDates(startDate : Date, interval : TimeInterval) -> Date{
        
        var start = startDate
        // if this is the next date for the med (so previous date was today)
        if Calendar.current.compare(start.addingTimeInterval(-1 * interval),
                                    to: Date.now, toGranularity: .day) == .orderedSame {
            
            start = start.addingTimeInterval( -1 * interval)
            while Calendar.current.compare(start, to: Date.now, toGranularity: .day) == .orderedSame {
                start = start.addingTimeInterval(-1 * interval)
            }
            
            start = start.addingTimeInterval(interval)
            
        }
        
        return start
    }
}
