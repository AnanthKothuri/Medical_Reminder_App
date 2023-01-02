//
//  ProfilePicture.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/10/22.
//

import SwiftUI

struct ProfilePicture: View {
    @State var image : UIImage? = nil
    @State var size : CGFloat

    
    var body: some View {
        Image(systemName: "person")
            .resizable()
            .frame(width: size, height: size, alignment: .center)
            .scaledToFit()
            .background(.white)
            .cornerRadius(size / 2)
            .padding()
        
        if image != nil {
            Image(uiImage: image!)
                .resizable()
                .frame(width: size, height: size, alignment: .center)
                .scaledToFit()
                .cornerRadius(size / 2)
//                .overlay(
//                    RoundedRectangle(cornerRadius: size / 2)
//                        .stroke(.white, lineWidth: 5)
//                )
                .shadow(color: .black, radius: 2)
                .padding()
        }
    }
}

struct ProfilePicture_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePicture(image: nil, size: 100)
    }
}
