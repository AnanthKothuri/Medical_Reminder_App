//
//  Reminder.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/14/22.
//

import SwiftUI

struct MedReminder: View {
    @State var med : Med
    var medName : String
    
    var formatter : NumberFormatter {
        var formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: nil) {
            
            // med name
            HStack {
                Text("\(medName.capitalized)")
                    .font(Font.custom("NunitoSans-Bold", size: 14))
                
                Image(systemName: "allergens")
                    .foregroundColor(.blue)
            }
            
            Divider()
            // med dosage
            HStack {
                Text("Dosage:")
                    .font(Font.custom("NunitoSans-Light", size: 12))
                
                Text("\(formatter.string(from: med.medDosage! as NSNumber)!) \(med.medDosageUnit ?? "Unknown")")
                    .font(Font.custom("NunitoSans-Regular", size: 12))
            }
            
            // med frequency
            HStack {
                Text("Frequency:")
                    .font(Font.custom("NunitoSans-Light", size: 12))
                
                Text("\(med.medFrequencyString)")
                    .font(Font.custom("NunitoSans-Regular", size: 12))
            }
            
            // next time for med
            HStack {
                Text("Next Date")
                    .font(Font.custom("NunitoSans-Light", size: 12))
                
                Text("\(med.medStartDate.formatted(date: .numeric, time: .omitted))")
                    .font(Font.custom("NunitoSans-Regular", size: 12))
                    .foregroundColor(.blue)
            }
            HStack {
                Text("End Date:")
                    .font(Font.custom("NunitoSans-Light", size: 12))
                
                Text("\(med.medEndDate != Date.distantFuture ? med.medEndDate.formatted(date: .numeric, time: .omitted) : "None")")
                    .font(Font.custom("NunitoSans-Regular", size: 12))
                    .foregroundColor(.blue)
            }
            
            HStack(alignment: .top, spacing: nil) {
                Text("Notes:")
                    .font(Font.custom("NunitoSans-Light", size: 12))
                
                Text("\(med.medNotes ?? "None")")
                    .font(Font.custom("NunitoSans-Regular", size: 12))
            }
            
            Spacer()
        }
        .padding(10)
        .frame(width: 150, height: 200, alignment: .center)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.blue, lineWidth: 1)
                //.shadow(color: .blue, radius: 5, x: 0, y: 0)
        )
    }
}

struct MedReminder_Previews: PreviewProvider {
    static var previews: some View {
        MedReminder(
            med: Med(name: "tylenol",
                     dosage: 3,
                     dosageUnit: "mg",
                     frequency: 10,
                     frequencyString: "Every 10 seconds",
                     startDate: Date(),
                     endDate: Date.distantFuture,
                     note: "these are some sample notes, very cooland i like to add on to them because they can be super long",
                     completionDates: []
                    ),
            medName: "tylenol"
        )
    }
}
