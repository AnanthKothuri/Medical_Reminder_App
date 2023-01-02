//
//  SpeechManager.swift
//  MedReminderSwiftUI
//
//  Created by Ananth Kothuri on 12/16/22.
//

import Foundation
import AVFoundation

class SpeechManager: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechManager()
    let synth = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        synth.delegate = self
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .duckOthers)
        } catch {
            print("error in speech manager")
        }
    }
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure the utterance.
        utterance.rate = 0.5
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        
        let voice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex)
        utterance.voice = voice
        
        // now turning this to speech synthesizer
        synth.speak(utterance)
    }
    
    // runs when speech finishes talking
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let lm = ListeningManager()
        lm.listenForConfirmation()
    }
}
