//
//  Doctor.swift
//  MedicalReminderApp
//
//  Created by Ananth Kothuri on 9/23/22.
//

import Foundation
import UIKit
class Doctor: User {

    var patients: [String: String?]
    
    // for encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case patients
    }
    
    init(userID: String, userType: String, firstName: String, lastName: String, email: String, profilePicture: UIImage?, patients: [String: String?]?, settings: Setting) {
        
        self.patients = patients == nil ? [:] : patients!
        super.init(userID: userID, userType: userType, firstName: firstName, lastName: lastName, email: email, profilePicture: profilePicture, settings: settings)
        
        //self.dictionary["patients"] = self.patients
    }
    
    // default constructor, only for testing
    init() {
        patients = ["tester": nil]
        super.init(userID: "Antanant", userType: "D", firstName: "Ananth", lastName: "Kothuri", email: "ananthkothuri.testing@gmail.com", profilePicture: nil, settings: Setting())
        
        //self.dictionary["patients"] = self.patients
    }
    
    // for decoder
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.patients = try container.decode([String: String?].self, forKey: .patients)
        
        try super.init(from: decoder)
    }
    
    // for encoder
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
        
        try container.encode(patients, forKey: .patients)
    }
}
