//
//  ListeningManager.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 12/20/22.
//

import Foundation
import AVFoundation
import Speech


class ListeningManager {
    
    private let speechRecognizer = SFSpeechRecognizer(locale:
                                                        Locale(identifier: "en-US"))!
    private var speechRecognitionRequest : SFSpeechAudioBufferRecognitionRequest?
    private var speechRecognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // variables for confirmation listening
    var confirmation = false
    private let confirmationList = ["ok", "thank you", "done", "end", "got it", "confirmed"]
    private var hasSpoken = false
    
    
    func listen() {
        print("started listening")
        try! startSession()
    }
    
    func listenForConfirmation() {
        confirmation = false
        hasSpoken = false
        print("started listening for confimation")
        
        try! startSession()
        
        // stop listening after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.stopListening()
            
        }
    }
    
    
    func startSession() throws {
        
        // if recognition task is already created, reset it
        if let recognitionTask = speechRecognitionTask {
            recognitionTask.cancel()
            self.speechRecognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSession.Category.record)
        speechRecognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = speechRecognitionRequest else { fatalError("SFSpeechAudioBufferRecognitionRequest object creation failed") }
        
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            
            self.speechRecognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        
        // doing the actual speech recognition
        speechRecognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            
            var finished = false
            
            if let result = result {
                let finalList =
                result.bestTranscription.formattedString.split(separator: " ")
                
                if finalList.count > 0 {
                    let word = finalList[finalList.count - 1]
                    finished = result.isFinal
                    
                    print("text: \(word)")
                    
                    if self.confirmationList.contains(word.lowercased()) {
                        self.confirmation = true
                        if (!self.hasSpoken) {
                            SpeechManager.shared.speak(text: "Thank you")
                            self.hasSpoken = true
                        }
                    }
                }
                
            }
            
            if error != nil || finished || self.confirmation
            {
                self.stopListening()
            }
        }
    }
    
    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            speechRecognitionRequest?.endAudio()
            print("stopped listening")
        }
    }
}
