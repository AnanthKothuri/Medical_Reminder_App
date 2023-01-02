//
//  Utils.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/9/22.
//


// class meant for using repeatable methods and models throughout
// the app

import Foundation
import BackgroundTasks

struct Utils {
    static let shared = Utils()
    
    var api =  MedicineInfoAPI()
    var auth = AuthManager()
    var allBasicPatientInfo : [BasicUser] {
        var list : [BasicUser] = []
        let dict = api.getAllBasicPatients()!
        for username in dict.keys {
            list.append(dictToBasicPatient(username: username, dict: dict[username] as! [String : String]))
        }
        
        return list
    }
    
    func getApi() -> MedicineInfoAPI {
        return api
    }
    
    func getAuth() -> AuthManager {
        return auth
    }
    
    func dictToBasicPatient(username: String, dict: [String: String]) -> BasicUser {
        return BasicUser(
            userID: username,
            userType: dict["userType"] ?? "(none)",
            firstName: dict["firstName"] ?? "(none)",
            lastName: dict["lastName"] ?? "(none)",
            profilePicture: nil)
    }
    
    func dictToUser(dictionary : [String: Any]?) -> User? {
        guard let dict = dictionary else {
            return nil
        }

        let userType = dict["userType"] as! String == "D" ? UserType.Doctor : UserType.Patient
        // let pic = dict["picture"] as! String


        if userType == UserType.Doctor {
            return Doctor(userID: dict["userID"] as! String,
                userType: dict["userType"] as! String,
                firstName: dict["firstName"] as! String,
                lastName: dict["lastName"] as! String,
                email: dict["email"] as! String,
                profilePicture: nil,
                patients: dict["patients"] as? [String : String?],
                settings: Setting(settings: dict["settings"] as! [String : Any]))

        } else {
            return Patient(userID: dict["userID"] as! String,
                userType: dict["userType"] as! String,
                firstName: dict["firstName"] as! String,
                lastName: dict["lastName"] as! String,
                email: dict["email"] as! String,
                profilePicture: nil,
                medications: dict["medications"] as? [String : Any],
                settings: Setting(settings: dict["settings"] as! [String : Any]))
        }
    }
    
    // saves the current user to UserDefaults
    func saveToUserDefaults(user: User) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(user.userType == .Patient ?
                                          user as! Patient :
                                            user as! Doctor)
            UserDefaults.standard.set(data, forKey: "loggedInUser")

        } catch {
            print("Unable to Encode Note (\(error))")
        }
    }
    
    // makes first refresh call, starting recurring cycle
    func scheduleFirstRefresh() {
        
        let request = BGAppRefreshTaskRequest(identifier: "MedicineApp")
        request.earliestBeginDate = Date(timeInterval: 5, since: .now)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print(error.localizedDescription)
        }
        
        BGTaskScheduler.shared.getPendingTaskRequests(completionHandler: { request in
            print("First Refresh, print pending task requests: \(request)")
        })
    }
}
