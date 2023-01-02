//
//  DoctorNoteView.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 10/23/22.
//

import SwiftUI

struct DoctorNoteView: View {
    var util: Utils
    @Binding var addSegue: Bool
    @Binding var user: Patient
    @State var note: String = "Note: "
    @State private var errorMessage = ""
    var mainFormatter = DateFormatter()
    
    var body: some View {
        ZStack{

            ScrollView {
                VStack(alignment: .center, spacing: nil) {
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
                    Text("Add Doctor Note")
                        .font(Font.custom("NunitoSans-SemiBold", size: 20))
                        .padding()
                    
                    // Requirements
                    Text("To successfully create a new medication, the note must contain the name, dosage, and frequency of the medication.\nIMPORTANT: Please don't write out numbers (like \"one\"). Also, any dates must be in the form MM-DD-YYYY")
                        .font(Font.custom("NunitoSans-Light", size: 15))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    
                    // example note
                    Text("EX: Take 2 mg of tylenol, 2 times a day, starting from 01-01-2001 to 12-31-2022")
                        .font(Font.custom("NunitoSans-Light", size: 15))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    
                    
                    // errorMessage
                    Text(errorMessage)
                        .font(Font.custom("NunitoSans-Light", size: 15))
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundColor(.blue)
                    
                    // Note field
                    TextEditor(text: $note)
                        .font(Font.custom("NunitoSans-Light", size: 20))
                        .multilineTextAlignment(.leading)
                        .frame(width: nil, height: 170, alignment: .center)
                        .disableAutocorrection(true)
                        .padding(20)
                    
                    // add med button
                    Button(action: {
                        errorMessage = ""
                        if let dict = util.api.noteToMed(note: note) {
                            
                            if dict["medName"] == nil ||
                                dict["medDosageString"] == nil ||
                                dict["medNote"] == nil ||
                                dict["medFrequencyString"] == nil {
                                errorMessage = "Invalid note. Please check that all requirements have been met."
                                return
                            }
                            
                            // can add med now
                            errorMessage = "Successfully added medication!"
                            
                            if let newMed = getMed(dict: dict) {
                                // adding to database
                                util.api.addMedicationToPatient(getUserID: user.userID, getUserType: "P", medName: newMed.medName, medDosage: newMed.medDosage ?? 0, medDosageUnit: newMed.medDosageUnit ?? "", medFrequency: newMed.medFrequency, medFrequencyString: newMed.medFrequencyString, startDate: mainFormatter.string(from: newMed.medStartDate), endDate: mainFormatter.string(from: newMed.medEndDate), medNotes: newMed.medNotes)
                                
                                util.saveToUserDefaults(user: user)
                                
                                // adding to current user
                                user.medications.append(newMed)
                                addSegue.toggle()
                            }
                            
                            
                        } else {
                            errorMessage = "Internal server error, please wait or report the problem."
                        }
                    }, label: {
                        Text("Add Med")
                            .font(Font.custom("NunitoSans-Light", size: 20))
                    })
                        .buttonStyle(.bordered)
                        .padding()
                    
                    // swipe text
                    Text("Swipe to manually add medicine")
                        .font(Font.custom("NunitoSans-Light", size: 15))
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Spacer(minLength: 40)
                }
            }
            
        }

    }
    
    func getMed(dict: [String: Any]) -> Med? {
        mainFormatter.dateFormat = "MM/dd/yyyy"
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MM/dd/yyyy"
        
        var startDate : Date? = nil
        var endDate : Date? = nil
        
        // getting the first date
        if dict["medDate1"] != nil {
            if let date1 = formatter.date(from: dict["medDate1"] as! String) {
                startDate = date1
                
            } else {
                errorMessage = "Error decoding given date(s)."
                return nil
            }
        }
        
        // getting second date if there
        if dict["medDate2"] != nil {
            if let date2 = formatter.date(from: dict["medDate2"] as! String) {
                endDate = date2
                
            } else {
                errorMessage = "Error decoding given date(s)."
                return nil
            }
        }
        
        // if both dates present, put in the right order
        if endDate != nil, startDate != nil {
            if endDate! < startDate! {
                let temp = startDate
                startDate = endDate
                endDate = temp
            }
            
            // checking if dates are after the current date
            if Calendar.current.compare(startDate!, to: Date.now, toGranularity: .day) == .orderedAscending {
                errorMessage = "Start date should be on or after the current date."
                return nil
            }
        }
        
        // creating the med with finalized dates
        return Med(
            name: dict["medName"] as! String,
            dosage: dict["medDosage"] as? Double,
            dosageUnit: dict["medDosageUnit"] as? String,
            frequency: dict["medFrequency"] as? Double,
            frequencyString: dict["medFrequencyString"] as! String,
            startDate: startDate ?? Date.now,
            endDate: endDate ?? Date.distantFuture,
            note: dict["medNote"] as? String,
            completionDates: []
        )
    }
}

struct DoctorNoteView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorNoteView(util: Utils(),
                       addSegue: .constant(true),
                       user: .constant(Patient())
        )
    }
}
