//
//  AddMedView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/16/22.
//

import SwiftUI

struct AddMedView: View {
    var util: Utils
    @Binding var addSegue: Bool
    @Binding var user: Patient
    
    var body: some View {
        // adding a med
        TabView {
            DoctorNoteView(util: util, addSegue: $addSegue, user: $user)
            ManualAddMed(util: util, addSegue: $addSegue, user: $user)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct AddMedView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedView(util: Utils(),
                   addSegue: .constant(true),
                   user: .constant(Patient())
        )
    }
}
