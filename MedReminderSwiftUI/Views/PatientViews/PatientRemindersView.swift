//
//  PatientRemindersView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/9/22.
//

import SwiftUI

struct PatientRemindersView: View {
    @Binding var user: Patient
    var util: Utils
    
    var body: some View {
        VStack(alignment: .leading) {
            // title
            Text("Hello \(user.firstName)!")
                .font(Font.custom("NunitoSans-Bold", size: 40))
                .multilineTextAlignment(.leading)
                .padding()
            
            Divider()
            
            PatientRemindersToDoctor(util: util, user: $user)
        }
    }
}

struct PatientRemindersView_Previews: PreviewProvider {
    static var previews: some View {
        PatientRemindersView(user: .constant(
            Patient()),
            util: Utils()
        )
    }
}
