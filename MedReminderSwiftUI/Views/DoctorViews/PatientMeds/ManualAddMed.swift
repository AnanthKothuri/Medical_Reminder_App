//
//  ManualAddMed.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/22/22.
//

import SwiftUI

struct ManualAddMed: View {
    var util: Utils
    var nH = NotificationHandler()
    @Binding var addSegue: Bool
    @Binding var user: Patient
    @State private var errorMessage = "Hour"
    var formatter = DateFormatter()
    let intervals = ["Hour", "Day", "Week", "Month", "Year"]
    
    // med variables
    @State var medName = ""
    @State var medDosage = ""
    @State var medDosageUnit = ""
    @State var medFrequencyNum = ""
    @State var medFrequencyInterval = ""
    @State var medStartDate: Date = Date()
    @State var medEndDate: Date = Date().addingTimeInterval(86_400)
    @State var medNote = ""
    
    var body: some View {
        ZStack {
            VStack {
                // x button
                Button(action: {
                    addSegue.toggle()
                }, label: {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding()
                })
                
                // title label
                Text("Manually Add Medicine")
                    .font(Font.custom("NunitoSans-SemiBold", size: 20))
                    .padding()
                
                // form for adding a med
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        //error message
                        Text(errorMessage)
                            .font(Font.custom("NunitoSans-Regular", size: 12))
                            .foregroundColor(.blue)
                        
                        // medName
                        Group {
                            Text("Name")
                                .font(Font.custom("NunitoSans-Regular", size: 12))
                            Divider()
                            
                            TextField("Name of Medication", text: $medName)
                                .frame(width: 250, height: nil, alignment: .top)
                                .font(Font.custom("NunitoSans-Light", size: 12))
                                .disableAutocorrection(true)
                        }
                        
                        
                        // med Dosage + unit
                        Group {
                            Text("Dosage (number) and unit")
                                .font(Font.custom("NunitoSans-Regular", size: 12))
                                .padding(.top, 20)
                            Divider()
                            
                            HStack {
                                
                                // medDosage
                                TextField("Dosage Amount", text: $medDosage)
                                    .font(Font.custom("NunitoSans-Light", size: 12))
                                    .disableAutocorrection(true)
                                    .keyboardType(.numberPad)
                                
                                // medDosageUnit
                                TextField(" Unit", text: $medDosageUnit)
                                    .font(Font.custom("NunitoSans-Regular", size: 12))
                                    .disableAutocorrection(true)
                            }
                        }
                        
                        // medFrequency
                        Group {
                            Text("Frequency")
                                .font(Font.custom("NunitoSans-Regular", size: 12))
                                .padding(.top, 20)
                            Divider()
                            
                            HStack {
                                // medFrequencyNum
                                TextField("Number", text: $medFrequencyNum)
                                    .font(Font.custom("NunitoSans-Regular", size: 12))
                                    .disableAutocorrection(true)
                                    .keyboardType(.numberPad)
                                    .frame(width: 50, height: nil, alignment: .center)
                                
                                Text("Per")
                                    .font(Font.custom("NunitoSans-Light", size: 12))
                                
                                // medFrequencyInterval
                                Picker("Choose a time interval", selection: $medFrequencyInterval) {
                                    ForEach(0 ..< intervals.count) { index in
                                        Text("\(intervals[index])").tag(intervals[index])
                                    }
                                }
                                Spacer()
                            }
                        }
                        
                        //med dates
                        Group {
                            Text("Start Date")
                                .font(Font.custom("NunitoSans-Regular", size: 12))
                                .padding(.top, 20)
                            
                            Divider()
                            DatePicker("Choose the starting date", selection: $medStartDate, in: Date()...)
                                .font(Font.custom("NunitoSans-Light", size: 12))
                        }
                        
                        Group {
                            Text("End Date")
                                .font(Font.custom("NunitoSans-Regular", size: 12))
                                .padding(.top, 20)
                            
                            Divider()
                            DatePicker("Choose the ending date", selection: $medEndDate, in: Date()...)
                                .font(Font.custom("NunitoSans-Light", size: 12))
                        }
                        
                        // optional note
                        Group {
                            Text("Note (Optional)")
                                .font(Font.custom("NunitoSans-Regular", size: 12))
                                .padding(.top, 20)
                            
                            Divider()
                            
                            TextEditor(text: $medNote)
                                .font(Font.custom("NunitoSans-Light", size: 12))
                                .multilineTextAlignment(.leading)
                                .frame(width: nil, height: 100, alignment: .center)
                                .padding(20)
                        }
                        
                    }
                }
                .padding()
                
                // add med button
                Button(action: {
                    if allValidFields() {
                        
                        // add med to database
                        util.api.addMedicationToPatient(
                            getUserID: user.userID,
                            getUserType: "P",
                            medName: medName,
                            medDosage: Double(medDosage)!,
                            medDosageUnit: medDosageUnit,
                            medFrequency: getFrequency(),
                            medFrequencyString: "\(medFrequencyNum)X per \(medFrequencyInterval)",
                            startDate: formatter.string(from: medStartDate),
                            endDate: formatter.string(from: medEndDate),
                            medNotes: medNote)
                        
                        util.saveToUserDefaults(user: user)
                        
                        user.medications.append(createNewMed())
                        addSegue.toggle()
                        
                        BackgroundManager.shared.mainRefresh()
                    }
                    
                }, label: {
                    Text("Add Med")
                        .font(Font.custom("NunitoSans-Light", size: 20))
                })
                    .buttonStyle(.bordered)
                    .padding()
                
                Spacer(minLength: 40)
            }
        }
    }
    
    func getFrequency() -> Double{
        if let freq = Double(medFrequencyNum) {
            if medFrequencyInterval == "Hour" {
                return 3_600 / freq
            } else if medFrequencyInterval == "Day" {
                return 86_400 / freq
            } else if medFrequencyInterval == "Week" {
                return 604_800 / freq
            } else if medFrequencyInterval == "Month" {
                return 2_592_000 / freq
            } else if medFrequencyInterval == "Year" {
                return 31_536_000 / freq
            }
        }
        print("\(medFrequencyNum), \(medFrequencyInterval)")
        
        return -1
    }
    
    func createNewMed() -> Med {
        return Med(name: medName,
                   dosage: Double(medDosage),
                   dosageUnit: medDosageUnit,
                   frequency: Double(medFrequencyNum),
                   frequencyString: "\(Double(medFrequencyNum) ?? 0)X per \(medFrequencyInterval)",
                   startDate: medStartDate,
                   endDate: medEndDate,
                   note: medNote,
                   completionDates: [])
    }
    
    func allValidFields() -> Bool {
        formatter.dateFormat = "MM/dd/yyyy"
        if medName != "" && medDosageUnit != "" {
            if let dos = Double(medDosage), let freq = Double(medFrequencyNum) {
                return true
                
            } else {
                errorMessage = "Dosage amount and frequency must be numbers"
                return false
            }
            
        } else {
            errorMessage = "All fields must be complete"
            return false
        }
    }
}

struct ManualAddMed_Previews: PreviewProvider {
    static var previews: some View {
        ManualAddMed(util: Utils(),
                     addSegue: .constant(true),
                     user: .constant(Patient())
        )
    }
}
