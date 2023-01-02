//
//  PatientRowView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/9/22.
//

import SwiftUI

struct PatientRowView: View {
    
    @State var user: BasicUser
    
    var body: some View {
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
        }
    }
}

struct PatientRowView_Previews: PreviewProvider {
    static var previews: some View {
        PatientRowView(user:
            Patient()
        )
    }
}
