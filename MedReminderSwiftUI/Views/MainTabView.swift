//
//  MainTabView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/8/22.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State var user: User
    var util: Utils
    
    var body: some View {
        
        Color.white
        if user.userType == .Doctor {
            TabView {
                DoctorPatientsView(
                    user: Binding(get: {user as! Doctor}, set: {_ in }),
                        util: util
                )
                    .tabItem {
                        Label("Patients", systemImage: "list.dash")
                    }
                
                DoctorProfile(
                        doctor: Binding(get: {user as! Doctor}, set: {_ in }),
                        util: util)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
            .onAppear {
                // starts the background refresh cycle
                NotificationHandler.shared.addBackgroundNotification(date: Date(timeInterval: 2, since: Date.now))
            }
            
            
        } else {
            TabView {
                PatientRemindersView(
                    user: Binding(get: {user as! Patient}, set: {_ in }),
                        util: util)
                    .tabItem {
                        Label("Reminders", systemImage: "list.dash")
                    }
                
                PatientProfile(
                    user: Binding(get: {user as! Patient}, set: {_ in }),
                               util: util)
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
            }
            .onAppear {
                // starts the background refresh cycle
                NotificationHandler.shared.addBackgroundNotification(date: Date(timeInterval: 1, since: Date.now))
                
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(user: User(userID: "Antanant", userType: "D", firstName: "Ananth", lastName: "Kothuri", email: "kothuria@gmail.com", profilePicture: nil, settings: Setting()),
            util: Utils())
    }
}
