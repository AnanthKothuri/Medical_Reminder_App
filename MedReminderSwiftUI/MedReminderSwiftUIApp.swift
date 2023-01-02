//
//  MedReminderSwiftUIApp.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/4/22.
//

import SwiftUI
import BackgroundTasks

@main
struct MedReminderSwiftUIApp : App {
    @ObservedObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(appState)
                .id(appState.rootViewId)
        }
    }
}
