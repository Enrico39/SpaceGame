//
//  SoundManager.swift
//  test game
//
//  Created by Michela D'Avino on 12/12/23.
//

import Foundation
import SpriteKit

let kBackgroundMusic = "backgroundMusic"
let kExtensionMusic = "mp3"
let kSoundState = "kSoundState"

class SoundManager {
    
    private init() {}
    
    static let shared = SoundManager()
    
    
    func setSound(_ state: Bool){
        UserDefaults.standard.set(state, forKey: kSoundState)
        UserDefaults.standard.synchronize()
    }
    
    func getSound() -> Bool {
        return UserDefaults.standard.bool(forKey: kSoundState)
    }
}
