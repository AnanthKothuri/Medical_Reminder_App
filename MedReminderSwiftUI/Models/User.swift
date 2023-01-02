//
//  User.swift
//  MedicalReminderApp
//
//  Created by Ananth Kothuri on 9/23/22.
//

import Foundation
import UIKit

class User : BasicUser {

    var email : String
    //var dictionary : [String: Any]
    var settings: Setting
    
    // for encoding and decoding
    private enum CodingKeys: String, CodingKey {
        case email
        case settings
    }
    
    
    init(userID: String, userType: String, firstName: String, lastName: String, email: String, profilePicture: UIImage?, settings: Setting) {
        self.email = email
        //self.dictionary = [:]
        self.settings = settings
        
        super.init(userID: userID, userType: userType, firstName: firstName, lastName: lastName, profilePicture: profilePicture)
        
//        self.dictionary = [
//            "userID": self.userID,
//            "userType": self.userType,
//            "firstName": self.firstName,
//            "lastName": self.lastName,
//            "email": self.email,
//            "settings": self.settings
//        ]
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.email = try container.decode(String.self, forKey: .email)
        self.settings = try container.decode(Setting.self, forKey: .settings)
        
        try super.init(from: decoder)
    }
    
    // for encoder
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
        
        try container.encode(email, forKey: .email)
        try container.encode(settings, forKey: .settings)
    }
}
