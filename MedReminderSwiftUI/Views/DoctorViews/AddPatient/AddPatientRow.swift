//
//  AddPatientRow.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/11/22.
//

import SwiftUI

struct AddPatientRow: View {
    var util: Utils
    @State var user: BasicUser
    @Binding var addSegue: Bool
    @Binding var doctor: Doctor
    @State private var isExpanded = false
    
    var body: some View {
            // normal row stuff
        HStack {
            // image
            ProfilePicture(image: nil, size: 25)
            
            // Name and username
            VStack(alignment: .leading, spacing: nil) {
                Text("\(user.firstName) \(user.lastName)")
                    .font(Font.custom("NunitoSans-Regular", size: 18))
                
                Text("\(user.userID)")
                    .font(Font.custom("NunitoSans-Light", size: 11))
            }
            Spacer()
            
            Button(action: {
                util.api.addPatientToDoctor(addPatientID: user.userID)
                doctor.patients[user.userID] = ""
                addSegue.toggle()
                
            }, label: {
                Text("Add")
                    .font(Font.custom("NunitoSans-Regular", size: 14))
            })
                .buttonStyle(.borderedProminent)
                .foregroundColor(.white)
                .padding()
        }
        
    }
}

struct AddPatientRow_Previews: PreviewProvider {
    static var previews: some View {
        AddPatientRow(util: Utils(),
            user:
            Patient(),
          addSegue: .constant(false),
          doctor:.constant(
          Doctor()
        ))
    }
}
