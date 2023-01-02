//
//  CompleteProfileView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/7/22.
//

import SwiftUI
import BackgroundTasks

struct CompleteProfileView: View {
    var util : Utils
    @State private var user: User? = nil
    @State private var userType = ""
    @State private var size : CGFloat = 200
    @State private var errorMessage = ""
    @State private var canContinue = false
    
    var body: some View {
        ZStack {
            Color.white
            
            VStack {
                // title
                Text("Complete Profile")
                    .font(Font.custom("NunitoSans-SemiBold", size: 40))
                    .padding()
                
                // profile pic text
                Text("Add a profile picture")
                    .font(Font.custom("NunitoSans-Regular", size: 20))
                    .padding()
                
                // picture button
                Button(action: {
                    
                }, label: {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: size / 2, height: size / 2, alignment: .center)
                        .scaledToFit()
                        .cornerRadius(size / 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: size / 2)
                                .stroke(.white, lineWidth: 5)
                                .frame(width: size, height: size, alignment: .center)
                        )
                        .shadow(color: .black, radius: 2)
                })
                    .buttonStyle(.plain)
                    .padding(Edge.Set.top, 60)
                    .padding(Edge.Set.bottom, 80)
                
                
                Divider()
                    .padding()
            
                HStack {
                    
                    Text("User Type: ")
                        .font(Font.custom("NunitoSans-Regular", size: 14))
                        .padding()
                    // picker
                    Picker("What type of user are you?", selection: $userType) {
                        Text("Choose type").tag("")
                            .font(Font.custom("NunitoSans-Regular", size: 14))
                        Text("Doctor").tag("D")
                            .font(Font.custom("NunitoSans-Regular", size: 14))
                        Text("Patient").tag("P")
                            .font(Font.custom("NunitoSans-Regular", size: 14))
                    }
                    .pickerStyle(.menu)
                    .padding()
                }
                .background(Color.init(.sRGB, red: 0.95, green: 0.95, blue: 0.95, opacity: 1))
                .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(.blue, lineWidth: 3))
                .cornerRadius(10)
                
                Text(errorMessage)
                    .font(Font.custom("NunitoSans-Light", size: 14))
                    .foregroundColor(.blue)
                
                Button("Continue") {
                    // checking if we can create user
                    if userType != "" {
                        canContinue.toggle()
                        createUser()
                        
                        // starts the background refresh cycle
                        NotificationHandler.shared.addBackgroundNotification(date: Date(timeInterval: 5, since: .now))
                        
                    } else {
                        errorMessage = "Must choose a user type"
                    }
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
            
            
            ZStack {
                if canContinue {
                    if user != nil {
                        MainTabView(user: user!, util: util)
                            .transition(.move(edge: .trailing))
                            .animation(.spring())
                    }
                }
            }
        }
    }
    
    // other methods
    func createUser() {
        
        // make profile pic choice (for now, it stays nil)
        
        let r = util.auth.getAttributes()
        let fullname = r["name"] as! String
        let str = fullname.trimmingCharacters(in: .whitespacesAndNewlines)
        let fn = str.components(separatedBy: " ")
        
        var dict : [String: Any] = [:]
        dict["userID"] = r["username"]
        dict["email"] = r["email"]
        dict["userType"] = userType == "Doctor" ? "D" : "P"
        dict["firstName"] = fn[0]
        dict["lastName"] = fn[1]
        dict["picture"] = ""  // normally would do pic.toPngString()
        if userType == "Doctor" {
            dict["patients"] = nil
        } else {
            dict["medications"] = nil
        }
        
        if let response = util.api.createUser(newUser: dict) {
            if response["SUCCESS"] != nil {
                // adding settings
                dict["settings"] = Setting(doctorCanAddReminders: true, endTimeLimit: "19:00", pauseNotifications: false, remindAtAnyTime: false, reportEmailDestination: "", sendWeeklyReports: true, startTimeLimit: "8:00", voiceReminders: true)
                user = util.dictToUser(dictionary: dict)
                util.saveToUserDefaults(user: user!)
                
            } else {
                print(response)
            }
        } else {
            print("Could not create user")
        }
    }
}

struct CompleteProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteProfileView(util: Utils())
    }
}
