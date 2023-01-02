//
//  DoctorProfile.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/13/22.
//

import SwiftUI

struct DoctorProfile: View {
    @EnvironmentObject var appState: AppState
    @Binding var doctor: Doctor
    @State var presentAlert = false
    var util: Utils
    
    var body: some View {

        NavigationView {
            ScrollView {
                VStack {
                    Profile(user: doctor)
                    
                    // contact
                    VStack(alignment: .leading, spacing: nil) {
                        Text("Contact")
                            .font(Font.custom("NunitoSans-Regular", size: 14))
                        Divider()
                        Text("\(doctor.email)")
                            .font(Font.custom("NunitoSans-Light", size: 14))
                    }
                    .padding()
                    
                    // Patient info
                    VStack(alignment: .leading, spacing: nil) {
                        Text("Patients")
                            .font(Font.custom("NunitoSans-Regular", size: 14))
                        Divider()
                        // number of patients
                        Text("\(doctor.patients.count ) patient\(doctor.patients.count == 1 ? "" : "s")")
                            .font(Font.custom("NunitoSans-Light", size: 14))
                    }
                    .padding()
                    
                    NavigationLink("Go to Settings", destination: SettingsView(user: Binding(get: {doctor as User}, set: {_ in }), util: util))
                        .padding()
                        .foregroundColor(.red)
                        .buttonStyle(.bordered)
                    
                    
                    // logout button
                    Button(action: {
                        presentAlert.toggle()
                    }, label: {
                        Text("Log Out")
                            .foregroundColor(.blue)
                    })
                    .alert("Are you sure you want to log out?", isPresented: $presentAlert) {
                        Button("Cancel", role: .cancel) {
                            presentAlert.toggle()
                        }
                        
                        Button("Log Out", role: .destructive) {
                            
                            // actually logging out
                            util.auth.signOut()
                            
                            // popping to login screen
                            Thread.sleep(forTimeInterval: 1)
                            appState.rootViewId = UUID()
                        }
                        
                    }
                    .padding(.init(top: 10, leading: 0, bottom: 40, trailing: 0))
                    
                }
                .navigationTitle("Dr. \(doctor.lastName)'s Profile")
                .navigationBarHidden(false)
            }
        }
        
        
    }
}

struct DoctorProfile_Previews: PreviewProvider {
    static var previews: some View {
        DoctorProfile(doctor: .constant(
            Doctor()), util: Utils())
    }
}
