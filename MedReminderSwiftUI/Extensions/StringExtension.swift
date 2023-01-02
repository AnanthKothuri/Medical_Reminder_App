//
//  StringExtension.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 12/21/22.
//

import Foundation

extension String: Identifiable {
    public var id: Int {
        return hash
    }
    
    
}
