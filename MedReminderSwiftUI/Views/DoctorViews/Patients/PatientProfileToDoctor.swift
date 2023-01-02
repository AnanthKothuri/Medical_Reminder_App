//
//  PatientProfileToDoctor.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/14/22.
//

import SwiftUI

struct PatientProfileToDoctor: View {
    var util: Utils
    //@Binding var rootActive: Bool
    @Binding var doctor: Doctor
    @State var user: Patient
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {

            ZStack {
                VStack {
                    // basic profile
                    Profile(user: user)
                    
                    Divider()
                    
                    VStack {
                        

                        // view medications button
                        
                        NavigationLink(destination: {
                            DoctorViewOfPatientReminders(util: util, user: $user)
                            
                        }, label: {
                            Text("View Medications")
                                .font(Font.custom("NunitoSans-Regular", size: 14))
                                .multilineTextAlignment(.leading)
                        })
                            .buttonStyle(.bordered)
                            .padding()

                        
                        // remove patient button
                        Button(action: {
                            util.api.removePatientFromDoctor(removeID: user.userID)
                            doctor.patients.removeValue(forKey: user.userID)
                            
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Remove Patient")
                                .font(Font.custom("NunitoSans-Regular", size: 14))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.red)
                        })
                            .padding()
                
                    }
                }
            }
            .navigationTitle("\(user.firstName) \(user.lastName)")
            .font(Font.custom("NunitoSans-Bold", size: 25))
            .multilineTextAlignment(.leading)
            .navigationBarHidden(false)
        
        
        
    }
}

struct PatientProfileToDoctor_Previews: PreviewProvider {
    static var previews: some View {
        PatientProfileToDoctor(
            util: Utils(),
            doctor: .constant(
                Doctor()),
            user: Patient()
        )
    }
}
