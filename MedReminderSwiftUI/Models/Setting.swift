//
//  Setting.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 12/14/22.
//

import Foundation

class Setting: Codable {
    var doctorCanAddReminders: Bool
    var endTimeLimit: String
    var pauseNotifications: Bool
    var remindAtAnyTime: Bool
    var reportEmailDestination: String
    var sendWeeklyReports: Bool
    var startTimeLimit: String
    var voiceReminders: Bool
    
    init(doctorCanAddReminders: Bool, endTimeLimit: String, pauseNotifications: Bool, remindAtAnyTime: Bool, reportEmailDestination: String, sendWeeklyReports: Bool, startTimeLimit: String, voiceReminders: Bool) {
        
        self.doctorCanAddReminders = doctorCanAddReminders
        self.endTimeLimit = endTimeLimit
        self.pauseNotifications = pauseNotifications
        self.remindAtAnyTime = remindAtAnyTime
        self.reportEmailDestination = reportEmailDestination
        self.sendWeeklyReports = sendWeeklyReports
        self.startTimeLimit = startTimeLimit
        self.voiceReminders = voiceReminders
    }
    
    convenience init(settings: [String: Any]) {
        if settings.isEmpty {
            self.init()
        } else {
            self.init()
            self.doctorCanAddReminders = settings["doctorCanAddReminders"] as! Bool
            self.endTimeLimit = settings["endTimeLimit"] as! String
            self.pauseNotifications = settings["pauseNotifications"] as! Bool
            self.remindAtAnyTime = settings["remindAtAnyTime"] as! Bool
            self.reportEmailDestination = settings["reportEmailDestination"] as! String
            self.sendWeeklyReports = settings["sendWeeklyReports"] as! Bool
            self.startTimeLimit = settings["startTimeLimit"] as! String
            self.voiceReminders = settings["voiceReminders"] as! Bool
        }
    }
    
    init() {
        self.doctorCanAddReminders = true
        self.endTimeLimit = "19:00"
        self.pauseNotifications = false
        self.remindAtAnyTime = false
        self.reportEmailDestination = ""
        self.sendWeeklyReports = true
        self.startTimeLimit = "8:00"
        self.voiceReminders = true
    }
    
    func getDictionary() -> [String : Any] {
        return [
            "doctorCanAddReminders" : doctorCanAddReminders,
            "endTimeLimit" : endTimeLimit,
            "pauseNotifications" : pauseNotifications,
            "remindAtAnyTime" : remindAtAnyTime,
            "reportEmailDestination" : reportEmailDestination,
            "sendWeeklyReports" : sendWeeklyReports,
            "startTimeLimit" : startTimeLimit,
            "voiceReminders" : voiceReminders
        ]
    }
    
}
