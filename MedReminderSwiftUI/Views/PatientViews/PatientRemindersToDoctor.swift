//
//  PatientRemindersToDoctor.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/14/22.
//

import SwiftUI

struct PatientRemindersToDoctor: View {
    var util: Utils
    @Binding var user: Patient
    @State var addSegue = false
    @State var medItems : [MedItem] = [
        MedItem(name: "Refresh", date: "Pull down to")
    ]
    
    var body: some View {
            
            VStack(alignment: .leading, spacing: nil) {
                // medication title
                Text("Medications")
                    .font(Font.custom("NunitoSans-SemiBold", size: 30))
                
                // horizontal scroll view for meds
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(user.medications) { med in
                            MedReminder(
                                med: med, medName: med.medName
                            )
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
                    }
                }
                .frame(width: nil, height: 200, alignment: .topLeading)
                .padding()
                
                
                // today's reminders
                Text("Today")
                    .font(Font.custom("NunitoSans-SemiBold", size: 30))
                
                Text("Pull down to refresh")
                    .font(Font.custom("NunitoSans-Light", size: 15))
                
                List {
                    
                    ForEach (medItems) { item in
                        
                        MedListItem(name: item.name, date: item.date)
                    }
                }
                .refreshable {
                    medItems = await NotificationHandler.shared.getPendingMedNotifications()
                }
                .listStyle(.inset)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Med Reminders")
            .navigationBarHidden(false)
            
    }
}

struct PatientRemindersToDoctor_Previews: PreviewProvider {
    static var previews: some View {
        PatientRemindersToDoctor(
            util: Utils(),
            user: .constant(
                Patient())
            )
    }
}
