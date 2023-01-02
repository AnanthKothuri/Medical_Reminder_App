//
//  DoctorViewOfPatientReminders.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 12/22/22.
//

import SwiftUI

struct DoctorViewOfPatientReminders: View {
    var util: Utils
    @Binding var user: Patient
    @State var addSegue = false

    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: nil) {
                // medication title
                Text("\(user.firstName)'s Medications")
                    .font(Font.custom("NunitoSans-SemiBold", size: 30))
                
                // horizontal scroll view for meds

                VStack {
                    ForEach(user.medications, id: \.id) { med in
                        
                        HStack(alignment: .top) {
                            MedReminder(
                                med: med, medName: med.medName
                            )
                            
                            VStack(alignment: .leading) {
                                Text("Full Notes")
                                    .font(Font.custom("NunitoSans-Bold", size: 14))
                                
                                Divider()
                                
                                Text("\(med.medNotes ?? "None")")
                                    .font(Font.custom("NunitoSans-Light", size: 12))
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                        }
                        
                        Button(action: {
                            removeMedication(med: med)

                        }, label: {
                            Text("Remove Medication")
                                .font(Font.custom("NunitoSans-Regular", size: 15))
                                .foregroundColor(.red)
                                .padding()
                        })
                    }
                }
                
                Button(action: {
                    addSegue.toggle()
                }, label: {
                    
                    HStack {
                        Text("Add Med")
                            .font(Font.custom("NunitoSans-Regular", size: 15))
                            .foregroundColor(.blue)
                        
                        Image(systemName: "plus")
                            .padding(7)
                            .background(.white)
                            .cornerRadius(50)
                            .overlay(Circle()
                                        .stroke()
                            )
                    }
                    
                })  //presenting the AddPatientView
                    .fullScreenCover(isPresented: $addSegue, onDismiss: nil) {
                        AddMedView(
                            util: util,
                            addSegue: $addSegue,
                            user: $user
                        )
                            .animation(.spring())
                    }
                    .padding()
                
                Spacer(minLength: 70)
            }
            .padding()
            .navigationTitle("Med Reminders")
            .navigationBarHidden(false)

        }
    }
    
    // method that actually removes med
    func removeMedication(med: Med) {
        util.api.removeMedicationFromPatient(getUserID: user.userID, getUserType: "P", removeMed: med.medName)
        
        let ndx = user.medications.firstIndex(of: med)!
        
        user.medications.remove(at: ndx)
    }
}

struct DoctorViewOfPatientReminders_Previews: PreviewProvider {
    static var previews: some View {
        DoctorViewOfPatientReminders(
            util: Utils(),
            user: .constant(Patient())
        )
    }
}
