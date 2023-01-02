//
//  Settings.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 12/20/22.
//

import SwiftUI

struct SettingsView: View {
    @Binding var user : User
    var util : Utils
    
    @State var startTime = ""
    @State var endTime = ""
    @State var errorMessage = ""
    
    @State var isEditing = true
    
    // storing the old values for the settings for editing mode
    @State var oldDoctorsCanAddReminders = false
    @State var oldPauseNotifications = false
    @State var oldRemindAtAnyTime = false
    @State var oldSendWeeklyReports = false
    @State var oldVoiceReminders = false

    
    var body: some View {
        
        ScrollView {
            VStack {
                
                
                // contains all switches
                TopSettingsView(user: $user, isEditing: $isEditing)
                
                Group {
                    // start time limit
                    
                    HStack {
                        Text("Earliest Daily Reminder Time")
                            .padding()
                        TextField("\(user.settings.startTimeLimit)", text: $startTime)
                    }
                    .padding()
                    .disabled(!isEditing)
                    
                    Divider()
                    
                    
                    
                    // end time limit
                    HStack {
                        Text("Latest Daily Reminder Time")
                            .padding()
                        TextField("\(user.settings.endTimeLimit)", text: $endTime)
                    }
                    .padding()
                    .disabled(!isEditing)
                    
                    Divider()
                    
                    // error message
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    // updates settings
                    Button("Update Settings") {
                        if isValid() {
                            // api call to update settings
                            updateSettings()
                            isEditing.toggle()
                        }
                    }
                    .disabled(!isEditing)
                    .padding()
                    .buttonStyle(.bordered)
                }
            }
            .navigationBarTitle("Settings")
            .navigationBarItems(trailing:
                                    
                Button(action: {
                    isEditing.toggle()
                
                    // reverting after not editing
                    if !isEditing {
                        let worked = updateOldVariables()
                    }
                    
                }, label: {
                    
                    if isEditing {
                        Text("Stop Editing")
                            .foregroundColor(.red)
                    } else {
                        Text("Edit")
                            .foregroundColor(.blue)
                    }
                
                })
                    
        
            )
            .navigationBarBackButtonHidden(isEditing)
            
        }
        .onAppear {
            
            oldVoiceReminders = user.settings.voiceReminders
            oldPauseNotifications = user.settings.pauseNotifications
            oldSendWeeklyReports = user.settings.sendWeeklyReports
            oldRemindAtAnyTime = user.settings.remindAtAnyTime
            oldDoctorsCanAddReminders = user.settings.doctorCanAddReminders
        }
        
    }
    
    private func updateOldVariables() -> Bool{
        user.settings.voiceReminders = oldVoiceReminders
        
        user.settings.sendWeeklyReports = oldSendWeeklyReports
        
        user.settings.remindAtAnyTime = oldRemindAtAnyTime
        
        user.settings.pauseNotifications = oldPauseNotifications
        
        user.settings.doctorCanAddReminders = oldDoctorsCanAddReminders
        
        startTime = ""
        endTime = ""
        errorMessage = ""
        
        return true
    }
    
    private func updateSettings() {
        if startTime != "" {
            user.settings.startTimeLimit = startTime
        }
        if endTime != "" {
            user.settings.endTimeLimit = endTime
        }

        util.saveToUserDefaults(user: user)
        util.api.updateSettings(settings: user.settings.getDictionary())
        
        // updating the old variables
        oldVoiceReminders = user.settings.voiceReminders
        oldPauseNotifications = user.settings.pauseNotifications
        oldSendWeeklyReports = user.settings.sendWeeklyReports
        oldRemindAtAnyTime = user.settings.remindAtAnyTime
        oldDoctorsCanAddReminders = user.settings.doctorCanAddReminders
        
        startTime = ""
        endTime = ""
        errorMessage = ""
        
        BackgroundManager.shared.mainRefresh()
        
    }
    
    private func isValid() -> Bool {
        if (startTime == "" && endTime == "") {
            return true
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        if let date1 = formatter.date(from: startTime), let date2 =
              formatter.date(from: endTime) {
            
            if date1.compare(date2) != .orderedAscending {
                errorMessage = "Earliest time must come before latest time."
                return false
            }
            
            return true
        }
        
        errorMessage = "Invalid earliest / latest times. Ensure format is HH:mm."
        return false
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(user: .constant(Patient()), util: Utils())
    }
}
