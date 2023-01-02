//
//  ProfilePictureView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/7/22.
//

import SwiftUI

struct ProfilePictureView: View {
    @State var imageName: String?
    @State var size: CGFloat
    
    var body: some View {
        
        Button(action: {
            
        }, label: {
            Image(systemName: "person")
                .resizable()
                .frame(width: size, height: size, alignment: .center)
                .scaledToFit()
                .cornerRadius(size / 2)
                .overlay(
                    RoundedRectangle(cornerRadius: size / 2)
                        .stroke(.white, lineWidth: 5)
                )
                .shadow(color: .black, radius: 2)
        })
        
    }
}

struct ProfilePictureView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePictureView(imageName: nil, size: 250)
    }
}
