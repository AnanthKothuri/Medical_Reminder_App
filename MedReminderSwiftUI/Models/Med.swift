//
//  Med.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/15/22.
//

import Foundation
import UIKit

class Med: Identifiable, Codable, Equatable, ObservableObject {
    static func == (lhs: Med, rhs: Med) -> Bool {
        return lhs.medName == rhs.medName &&
        lhs.medDosage == rhs.medDosage &&
        lhs.medDosageUnit == rhs.medDosageUnit &&
        lhs.medFrequency == rhs.medFrequency &&
        lhs.medStartDate == rhs.medStartDate &&
        lhs.medEndDate == rhs.medEndDate 
    }
    
    var medName: String
    var medNotes: String?
    var medDosage: Double?
    var medDosageUnit: String?
    var medFrequency: TimeInterval
    var medFrequencyString: String
    var medStartDate: Date
    var medEndDate: Date
    var medCompletionDates: [Date]
    
    init(name: String, dosage: Double?, dosageUnit: String?, frequency: Double?, frequencyString: String, startDate: Date, endDate: Date, note: String?, completionDates: [Date]?) {
        medName = name
        medNotes = note != nil ? note! : nil
        
        // dosage
        medDosage = dosage ?? 10
        medDosageUnit = dosageUnit ?? ""
        
        // frequency- default is 1 day
        medFrequency = frequency ?? 86_400
        medFrequencyString = frequencyString
        
        // dates
        medStartDate = startDate
        medEndDate = endDate
        medCompletionDates = completionDates ?? []
        
    }
    
    func getDictionary() -> [String: Any] {
        return [
            "medName": medName,
            "medNotes": medNotes,
            "medDosage": medDosage,
            "medDosageUnit": medDosageUnit,
            "medFrequency": medFrequency,
            "medFrequencyString": medFrequencyString,
            "medStartDate": medStartDate,
            "medEndDate": medEndDate,
            "medCompletionDates": medCompletionDates
        ]
    }
}
