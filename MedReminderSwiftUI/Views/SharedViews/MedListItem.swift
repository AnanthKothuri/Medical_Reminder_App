//
//  MedListItem.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/15/22.
//

import SwiftUI

struct MedListItem: View {
    @State var name : String
    @State var date : String
    
    var body: some View {
        HStack {
            
            Image(systemName: "pills.fill")
                .foregroundColor(.blue)
                .padding(.leading)

            Text(date)
                .padding()
                .font(Font.custom("NunitoSans-Bold", size: 15))
                
                .foregroundColor(.blue)
            
            Divider()
                .frame(height: 30)
            
            Text(name)
                .padding()
                .font(Font.custom("NunitoSans-Regular", size: 15))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(.blue, lineWidth: 1)
        )
        .scaledToFit()
    }
}

struct MedListItem_Previews: PreviewProvider {
    static var previews: some View {
        MedListItem(name: "Tylenol", date: "August 20th, 9:30 pm")
    }
}
