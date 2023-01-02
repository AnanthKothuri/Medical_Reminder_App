//
//  AddPatientView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/10/22.
//

import SwiftUI

struct AddPatientView: View {
    var util: Utils
    @Binding var addSegue: Bool
    @Binding var doctor: Doctor
    @State private var searchedUser = ""
    
    var body: some View {

        VStack {
            // exit button
            Button(action: {
                addSegue.toggle()
            }, label: {
                Image(systemName: "xmark")
                    .font(.title)
                    .foregroundColor(.blue)
                    .padding()
            })
            
            NavigationView {
                // using stack view instead of list
                ScrollView {
                    LazyVStack {
                        ForEach(filteredList) { user in
                            AddPatientRow(util: util, user: user, addSegue: $addSegue, doctor: $doctor)
                                .disabled(doctor.patients[user.userID] != nil)
                            
                            Divider()
                        }
                    }
                    .searchable(text: $searchedUser, placement: .toolbar, prompt: "Search all users")
                    .navigationTitle("Add Patients")
                    .navigationBarHidden(false)
                    .padding()
                }
                
                
                
                // list of potential patients
//                List(filteredList, id: \.userID) { user in
//                    AddPatientRow(util: util, user: user, addSegue: $addSegue, doctor: $doctor)
//                        .disabled(doctor.patients[user.userID] == nil)
//
//                }
//                .searchable(text: $searchedUser, placement: .toolbar, prompt: "Search all users")
//                .listStyle(.plain)
//                .navigationTitle("Add Patients")
//                .navigationBarHidden(false)
//                .padding()
            }
            
            Spacer()
        }
    
    }
    
    // -------------- other methods -----------------
    
    // filter the list of shown users for the search bar
    var filteredList: [BasicUser] {
        if searchedUser.isEmpty {
            return getAllPatients()
        }
        else {
            return getAllPatients()
                .filter {
                    $0.firstName.contains(searchedUser) ||
                    $0.lastName.contains(searchedUser) ||
                    $0.userID.contains(searchedUser)
                }
        }
    }
    
    // get all the basic patient info from the API
    func getAllPatients() -> [BasicUser] {
        return util.allBasicPatientInfo
    }
    
    // changes API patient info into a BasicUser
    func dictToBasicPatient(username: String, dict: [String: String]) -> BasicUser {
        return BasicUser(
            userID: username,
            userType: dict["userType"] ?? "(none)",
            firstName: dict["firstName"] ?? "(none)",
            lastName: dict["lastName"] ?? "(none)",
            profilePicture: nil)
    }
}

struct AddPatientView_Previews: PreviewProvider {
    static var previews: some View {
        AddPatientView(
            util: Utils(),
            addSegue: .constant(true),
            doctor: .constant(
                Doctor()
        ))
    }
}
