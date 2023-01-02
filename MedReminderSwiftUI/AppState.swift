//
//  AppState.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 12/29/22.
//

import Foundation

final class AppState : ObservableObject {
    @Published var rootViewId = UUID()
}
