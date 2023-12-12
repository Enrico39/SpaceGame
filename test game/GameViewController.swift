//
//  GameViewController.swift
//  test game
//
//  Created by Enrico Madonna on 07/12/23.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    lazy var backgroundMusic: AVAudioPlayer? = {
            guard let url =  Bundle.main.url(forResource: kBackgroundMusic, withExtension: kExtensionMusic) else {
                return nil
            }
            do{
                let player = try AVAudioPlayer(contentsOf: url)
                player.numberOfLoops = -1
                return player
            }catch{
                return nil
            }
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
            
            
        }
        
        playStopBackgroundMusic()
              
        SoundManager.shared.setSound(true)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func playStopBackgroundMusic() {
            if SoundManager.shared.getSound(){
                backgroundMusic?.play()
            } else {
                backgroundMusic?.stop()
            }
        }
        
        func run(_ fileName: String, onNode: SKNode){
            if SoundManager.shared.getSound() {
                onNode.run(SKAction.playSoundFileNamed(fileName, waitForCompletion: false))
            }
           
        }
    
}
