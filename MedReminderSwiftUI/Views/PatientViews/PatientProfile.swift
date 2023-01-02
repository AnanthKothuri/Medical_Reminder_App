//
//  PatientProfile.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/13/22.
//

import SwiftUI

struct PatientProfile: View {
    @EnvironmentObject var appState: AppState
    @Binding var user: Patient
    @State var presentAlert = false
    var util: Utils
    
    var body: some View {
        
        NavigationView {
            ScrollView {
                VStack {
                    Profile(user: user)
                    
                    // contact
                    VStack(alignment: .leading, spacing: nil) {
                        Text("Contact")
                            .font(Font.custom("NunitoSans-Regular", size: 14))
                        Divider()
                        Text("\(user.email)")
                            .font(Font.custom("NunitoSans-Light", size: 14))
                    }
                    .padding()
                    
                    // Patient info
                    VStack(alignment: .leading, spacing: nil) {
                        Text("Medications")
                            .font(Font.custom("NunitoSans-Regular", size: 14))
                        Divider()
                        // number of patients
                        Text("\(user.medications.count ) medication\(user.medications.count == 1 ? "" : "s")")
                            .font(Font.custom("NunitoSans-Light", size: 14))
                    }
                    .padding()
                    
                    // goes to settings
                    NavigationLink("Go to Settings", destination: SettingsView(user: Binding(get: {user as User}, set: {_ in }), util: util))
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
                .navigationTitle("\(user.firstName)'s Profile")
                .navigationBarHidden(false)
            }
        }
        
    }
}

struct PatientProfile_Previews: PreviewProvider {
    static var previews: some View {
        PatientProfile(
            user: .constant(Patient()),
            util: Utils())
    }
}
