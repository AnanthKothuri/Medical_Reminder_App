//
//  DoctorPatientsView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/9/22.
//

import SwiftUI

struct DoctorPatientsView: View {
    @Binding var user: Doctor
    @State private var searchedUser = ""
    @State private var addSegue = false
    var util: Utils
    @State var isActive = false
    
    var patientList: [Patient] {
        var list : [Patient] = []
        for key in user.patients.keys {
            let patient = util.api.getUser(getUserID: key, getUserType: "P")
            if let p = patient, let u = util.dictToUser(dictionary: p) as? Patient {
                list.append(u)
            }
        }
        list.sort {
            $0.userID < $1.userID
        }

        return list
    }

    
    var body: some View {
        
        NavigationView {
            
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: nil) {
                    // welcome message
                    Text("Welcome Dr. \(user.lastName)!")
                        .font(Font.custom("NunitoSans-Bold", size: 40))
                        .padding()
                        .fixedSize(horizontal: false, vertical: true)

                    
                    // list of current patients
                    Text("Your Patients")
                        .font(Font.custom("NunitoSans-Regular", size: 25))
                        .padding(Edge.Set.leading, 20)
                    
                    
                    List(filteredList, id: \.userID) { u in

                        NavigationLink(
                            destination: {
                                ScrollView {
                                    PatientProfileToDoctor(util: util, doctor: $user, user: u)
                                }
                            },
                            label: {
                                PatientRowView(user: u)
                            })

                    }
                    .searchable(text: $searchedUser, placement: .toolbar, prompt: "Search your patients")
                    .listStyle(.plain)
                        
                    Spacer()
                        .frame(width: nil, height: 80, alignment: .center)
                }
                .padding()
                
                // add patient button
                VStack {
                    Button(action: {
                        addSegue.toggle()
                    }, label: {
                        
                        HStack {
                            Text("Add patient")
                                .font(Font.custom("NunitoSans-Regular", size: 20))
                                .foregroundColor(.blue)
                            
                            Image(systemName: "plus")
                                .padding()
                                .background(.white)
                                .cornerRadius(50)
                                .overlay(Circle()
                                            .stroke()
                                )
                        }
                        
                    })  //presenting the AddPatientView
                        .fullScreenCover(isPresented: $addSegue, onDismiss: nil) {
                            AddPatientView(util: util, addSegue: $addSegue, doctor: $user)
                                .animation(.spring())
                        }
                        .padding()
                        .background(Color.init(.sRGB, red: 250, green: 250, blue: 250, opacity: 0.8))
                        .cornerRadius(40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.blue, lineWidth: 1)
                        )
                    
                    Spacer()
                        .frame(width: nil, height: 50, alignment: .center)
                }
                .padding()
                
            }
            .navigationTitle("Patients")
            .navigationBarHidden(false)
        }
    }
    
    var filteredList: [Patient] {
        if searchedUser.isEmpty {
            return patientList
        }
        else {
            return patientList
                .filter {
                    $0.firstName.contains(searchedUser) ||
                    $0.lastName.contains(searchedUser) ||
                    $0.userID.contains(searchedUser)
                }
        }
    }
    
    // Methods
//    func getPatientList(dict: [String: Any]) -> [Patient] {
//        var list : [Patient] = []
//        for key in dict.keys {
//            let patient = util.api.getUser(getUserID: key, getUserType: "P")
//            if let u = util.dictToUser(dictionary: patient) as? Patient {
//                list.append(u)
//            }
//        }
//
//        return list
//    }
}

struct DoctorPatientsView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorPatientsView(user: .constant(
            Doctor()),
            util: Utils())
    }
}
