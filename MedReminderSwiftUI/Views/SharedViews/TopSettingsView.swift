//
//  TopSettingsView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 12/21/22.
//

import SwiftUI

struct TopSettingsView: View {
    
    @Binding var user : User
    @Binding var isEditing : Bool
    var body: some View {
        VStack {
            // doctor can add reminders
            Toggle(isOn: $user.settings.doctorCanAddReminders, label: {
                Text("Doctor Can Add Reminders")
            })
            .padding()
            .disabled(!isEditing)
            
            Divider()
            
            // voice reminders
            Toggle(isOn: $user.settings.voiceReminders, label: {
                Text("Voice Reminders")
            })
            .padding()
            .disabled(!isEditing)
            
            Divider()
            
            // pause notifications
            Toggle(isOn: $user.settings.pauseNotifications, label: {
                Text("Pause Notifications")
            })
            .padding()
            .disabled(!isEditing)
            
            Divider()
            
            // remind at any time
            Toggle(isOn: $user.settings.remindAtAnyTime, label: {
                Text("Remind at Any Time")
            })
            .padding()
            .disabled(!isEditing)
            
            Divider()
            
            // send weekly reports
            Toggle(isOn: $user.settings.sendWeeklyReports, label: {
                Text("Send Weekly Reports")
            })
            .padding()
            .disabled(!isEditing)
            
            Divider()
        }
    }
}

struct TopSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        TopSettingsView(
            user: .constant(Patient()),
            isEditing: .constant(false)
        )
    }
}
