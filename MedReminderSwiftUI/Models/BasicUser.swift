//
//  BasicUser.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/11/22.
//

import Foundation
import UIKit

class BasicUser: Identifiable, Codable {

    var userType : UserType
    var userID : String
    var firstName : String
    var lastName : String
    // var profilePicture : UIImage?
    
    // for encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case userType
        case userID
        case firstName
        case lastName
    }
    
    
    init(userID: String, userType: String, firstName: String, lastName: String, profilePicture: UIImage?) {
        self.userID = userID
        self.firstName = firstName
        self.lastName = lastName
        // self.profilePicture = profilePicture
        self.userType = userType == "D" ? UserType.Doctor : UserType.Patient
    }
    
    // for decoder
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userType = try container.decode(UserType.self, forKey: .userType)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
    }
    
    // for encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userType, forKey: .userType)
        try container.encode(userID, forKey: .userID)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
    }
}
