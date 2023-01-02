//
//  Patient.swift
//  MedicalReminderApp
//
//  Created by Ananth Kothuri on 9/23/22.
//

import Foundation
import UIKit
class Patient: User {

    var medications: [Med] = []
    var medDictionary: [String: Med] = [:]
    
    // for encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case medications
        case medDictionary
    }
    
    init(userID: String, userType: String, firstName: String, lastName: String, email: String, profilePicture: UIImage?, medications: [String: Any]?, settings: Setting) {
        
        if medications == nil {
            self.medications = []
            self.medDictionary = [:]
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            
            for m in medications!.values {
                if let med = m as? [String: Any] {
                    print(med["medStartDate"])
                    let newMed = Med(name: med["medName"] as! String,
                                    dosage: Double(med["medDosage"] as! String),
                                    dosageUnit: med["medDosageUnit"] as? String,
                                    frequency: Double(med["medFrequency"] as! String),
                                    frequencyString: med["medFrequencyString"] as! String,
                                     startDate: formatter.date(from: med["medStartDate"] as! String) ?? Date(),
                                     endDate: formatter.date(from: med["medEndDate"] as! String) ?? Date.distantFuture,
                                    note: med["medNotes"] as? String,
                                    completionDates: med["medCompletionDates"] as? [Date])
                    
                    self.medications.append(newMed)
                    self.medDictionary[newMed.medName] = newMed
                }
                    
            }
        }
        
        super.init(userID: userID, userType: userType, firstName: firstName, lastName: lastName, email: email, profilePicture: profilePicture, settings: settings)
        
        // adding dictionary version of meds to this dictionary
        var medDict : [String: Any] = [:]
        for med in self.medications {
            medDict[med.medName] = med
        }
       // self.dictionary["medications"] = medDict
    }
    
    // default constructor, only for testing
    init() {
        medications = [Med(name: "Tylenol", dosage: 2, dosageUnit: "g", frequency: 10, frequencyString: "every 10 seconds", startDate: Date(), endDate: Date.distantFuture, note: "Testing string and medication", completionDates: nil)]
        medDictionary[medications[0].medName] = medications[0]
        
        super.init(userID: "tester", userType: "P", firstName: "Ananth", lastName: "Kothuri", email: "kothuria@gmail.com", profilePicture: nil, settings: Setting())
    }
    
    // for decoder
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try super.init(from: decoder)
        
        self.medications = try container.decode([Med].self, forKey: .medications)
        self.medDictionary = try container.decode([String: Med].self, forKey: .medDictionary)
    }
    
    // for encoder
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(medications, forKey: .medications)
        try container.encode(medDictionary, forKey: .medDictionary)
        try super.encode(to: encoder)
    }
}
