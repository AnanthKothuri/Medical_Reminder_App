//
//  MedItem.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 12/22/22.
//

import Foundation
class MedItem : Identifiable {
    var name : String
    var date : String
    
    init(name: String, date: String) {
        self.name = name
        self.date = date
    }
}
