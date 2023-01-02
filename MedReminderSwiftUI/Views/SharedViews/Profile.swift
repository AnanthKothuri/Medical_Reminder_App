//
//  Profile.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/13/22.
//

import SwiftUI

struct Profile: View {
    @State var user: BasicUser
    
    var body: some View {
        ZStack {
            VStack {
                // random background color strip
                Color.init(.sRGB, red: 0.7, green: 0.8, blue: 0.9, opacity: 1)
                    .frame(width: nil, height: 200, alignment: .center)
                
                // profile picture
                ProfilePicture(image: nil, size: 200)
                    .offset(x: 0, y: -150)
                    .padding(.bottom, -150)
                
                VStack(alignment: .leading, spacing: 5) {
                    
                    // name
                    Text("\(user.firstName) \(user.lastName)")
                        .font(Font.custom("NunitoSans-SemiBold", size: 20))
                    
                    // username
                    Text("\(user.userID)")
                        .font(Font.custom("NunitoSans-Regular", size: 14))
                    
                    Divider()
                        .padding(10)
                    // bio
                    Text("This is some sample bio information. Unfortunately I didn't program this part well enough yet but just ignore that for now hehehehehe.")
                        .font(Font.custom("NunitoSans-Light", size: 14))
                        .multilineTextAlignment(.leading)
                }
                .padding()
            }
        }
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile(user:
                Patient()
        )
    }
}
