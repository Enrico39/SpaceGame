//
//  GameScene.swift
//  test game
//
//  Created by Enrico Madonna(Beniamino Nardones wife) on 07/12/23.
//
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
 
    var groundNode: SKSpriteNode!
    var player: SKSpriteNode!
     var lastUpdateTime: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    var isPlayerJumping = false
    let runningActionKey = "runningAction"
    var runningFrames: [SKTexture] = []
    var shootFrames: [SKTexture] = []

    let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
    let restartLabel = SKLabelNode(fontNamed: "Chalkduster")
    var isGameOver = false
    let enemyCategory: UInt32 = 4
    var enemies: [SKSpriteNode] = []
    var introAnimationFrames: [SKTexture] = []
    let tapToPlayLabel = SKLabelNode(fontNamed: "Chalkduster")
    var animationNode: SKSpriteNode!
    

 
    var canRestart:Bool = false
    var deathFrames: [SKTexture] = []
  
    var moonGround1: SKSpriteNode!
    var moonGround2: SKSpriteNode!
    var moonGroundSpeed: CGFloat = 5.0

    override func didMove(to view: SKView) {
         // Imposta il delegate per la gestione dei contatti fisici
         self.physicsWorld.contactDelegate = self
         
         // Inizializza e avvia l'animazione introduttiva
         initializeIntroAnimation()
         playIntroAnimation()
         
         // Configura la gesture di swipe
         setupSwipeGesture(view: view)
         
         // Crea il terreno di gioco
         createGround()
         
    
         
         // Carica le texture per l'animazione di "shoot"
         loadShootTextures()
         
 
         // Crea i terreni lunari
         createMoonGrounds()
        
        createScrollingBackground()
         
     }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Gestione dei tocchi
        if isGameOver {
            restartGame()
        } else {
            if tapToPlayLabel.parent != nil {
                // Rimuovi le etichette di inizio gioco
                tapToPlayLabel.removeFromParent()
                animationNode.removeFromParent()
                startGame()
            } else {
                // Esegui l'animazione di "shoot"
               // shootPlayer()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let playerNode = player as SKNode
        let groundNode = groundNode as SKNode
        if !isGameOver{
            if (contact.bodyA.categoryBitMask == player.physicsBody?.categoryBitMask && contact.bodyB.categoryBitMask == groundNode.physicsBody?.categoryBitMask) ||
                (contact.bodyA.categoryBitMask == groundNode.physicsBody?.categoryBitMask && contact.bodyB.categoryBitMask == player.physicsBody?.categoryBitMask) {
                isPlayerJumping = false
                if player.action(forKey: runningActionKey) == nil {
                    let runningAction = SKAction.animate(with: runningFrames, timePerFrame: 0.1)
                    player.run(SKAction.repeatForever(runningAction), withKey: runningActionKey)
                }
            }}
        
        if (contact.bodyA.categoryBitMask == player.physicsBody?.categoryBitMask && contact.bodyB.categoryBitMask == enemyCategory) ||
            (contact.bodyA.categoryBitMask == enemyCategory && contact.bodyB.categoryBitMask == player.physicsBody?.categoryBitMask) {
            gameOver()
        }
        
        if !isGameOver && !isPlayerJumping {
            if player.action(forKey: runningActionKey) == nil {
                let runningAction = SKAction.animate(with: runningFrames, timePerFrame: 0.1)
                player.run(SKAction.repeatForever(runningAction), withKey: runningActionKey)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            deltaTime = currentTime - lastUpdateTime
        } else {
            deltaTime = 0
        }
        lastUpdateTime = currentTime
        
        
        if !isGameOver {
            if isPlayerJumping {
                if let velocity = player.physicsBody?.velocity.dy, velocity < 0 {
                    player.texture = SKTexture(imageNamed: "player-jump2")
                }
            }
          
            updateGroundPosition(moonGround1)
                updateGroundPosition(moonGround2)
         }
    }
    
    
  
}


//MARK: GROUND
extension GameScene{
    // Ottimizzazione della creazione del terreno di gioco
      func createGround() {
          groundNode = SKSpriteNode(imageNamed: "ground1")
          groundNode.position = CGPoint(x: frame.midX, y: -517)
          groundNode.size = CGSize(width: 1300, height: 500)
          groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
          groundNode.physicsBody?.isDynamic = false
          groundNode.physicsBody?.categoryBitMask = 1
          addChild(groundNode)
      }
    
    func createMoonGroundNode(imageName:String) -> SKSpriteNode {
        let moonGroundNode = SKSpriteNode(imageNamed: imageName)  // Usa "moon1" o "moon2" a seconda dell'asset desiderato
        moonGroundNode.position = CGPoint(x: frame.midX, y: groundNode.position.y+55)
        moonGroundNode.size = CGSize(width: 1900, height:400)  // Modifica la dimensione in base alle tue esigenze
        moonGroundNode.zPosition = 1
        return moonGroundNode
    }
    
    func createMoonGrounds() {
        moonGround1 = createMoonGroundNode(imageName: "moon1")
        moonGround2 = createMoonGroundNode(imageName: "moon2")
         moonGround2.position = CGPoint(x: moonGround1.position.x + moonGround1.size.width, y: moonGround1.position.y)

         addChild(moonGround1)
         addChild(moonGround2)
     }
    func updateGroundPosition(_ background: SKSpriteNode) {
        background.position = CGPoint(x: background.position.x - moonGroundSpeed, y: background.position.y)
        
        if background.position.x <= -background.size.width {
            background.position = CGPoint(x: background.size.width, y: background.position.y)
        }
    }

}

// MARK: Background
extension GameScene {
    func createBackgroundNode(imageName: String) -> SKSpriteNode {
        let backgroundNode = SKSpriteNode(imageNamed: imageName)
        backgroundNode.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundNode.size = CGSize(width: self.size.width, height: 800)
        backgroundNode.zPosition = -1
        return backgroundNode
    }

    func createScrollingBackground() {
        // Creazione dei nodi di sfondo
        let background1 = createBackgroundNode(imageName: "planets1")
        let background2 = createBackgroundNode(imageName: "bg2")

        // Posizionamento iniziale del secondo sfondo
        background2.position = CGPoint(x: background1.position.x + background1.size.width, y: background1.position.y)

        // Aggiunta dei nodi di sfondo alla scena
        addChild(background1)
        addChild(background2)

        // Array dei nodi di sfondo per un facile accesso
        let backgrounds = [background1, background2]

        // Funzione per aggiornare la posizione di ogni sfondo
        func updateBackgroundPosition() {
            for background in backgrounds {
                // Aggiorna la posizione di ogni sfondo
                background.position = CGPoint(x: background.position.x - moonGroundSpeed, y: background.position.y)
                
                // Quando un sfondo esce completamente dallo schermo, riposizionalo
                if background.position.x <= -background.size.width {
                    background.position = CGPoint(x: background.position.x + background.size.width * 2, y: background.position.y)
                }
            }
        }

        // Aggiungi l'aggiornamento della posizione allo SKAction
        let updateAction = SKAction.run(updateBackgroundPosition)
        let delayAction = SKAction.wait(forDuration: 0.03) // Regola il ritardo per controllare la velocità di scorrimento
        let updateLoopAction = SKAction.repeatForever(SKAction.sequence([updateAction, delayAction]))

        run(updateLoopAction)
    }

    // Altri metodi e proprietà della classe GameScene...
}




// MARK: ENEMIES
extension GameScene {
    func spawnEnemiesPeriodically() {
        let spawn = SKAction.run { [weak self] in
            self?.createEnemy()
        }
        let delay = SKAction.wait(forDuration: 2.0, withRange: 1.0)
        let spawnSequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(spawnSequence))
    }
    
    func createEnemy() {
        let enemy = SKSpriteNode(imageNamed: "alien1")
        enemy.position = CGPoint(x: 300, y: -217)
         enemy.size = CGSize(width: 60, height: 60)
        enemy.xScale = -1
        
        var walkFrames: [SKTexture] = []
        for i in 1...6 {
            walkFrames.append(SKTexture(imageNamed: "alien\(i)"))
        }
        let walkAction = SKAction.animate(with: walkFrames, timePerFrame: 0.1)
        enemy.run(SKAction.repeatForever(walkAction))
        
        enemy.physicsBody = SKPhysicsBody(texture: enemy.texture!, size: enemy.size)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.categoryBitMask = enemyCategory
        enemy.physicsBody?.contactTestBitMask = player.physicsBody!.categoryBitMask | groundNode.physicsBody!.categoryBitMask
        enemy.physicsBody?.collisionBitMask = groundNode.physicsBody!.categoryBitMask
        enemy.zPosition = 1
        
        let moveAction = SKAction.moveTo(x: -500, duration: 3.0)
        let removeAction = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([moveAction, removeAction]))
        
        addChild(enemy)
        enemies.append(enemy)
    }
}

// MARK: PLAYER
extension GameScene{
    func createLoveNode() {
        let loveNode = SKSpriteNode(imageNamed: "lovemeter8")
        loveNode.position = CGPoint(x: 0, y: 500)
        loveNode.size = CGSize(width: 700, height: 350)
        loveNode.zPosition = 1
        addChild(loveNode)
    }

    func createPlayer() {
        // Load the first frame to initialize the player
        let initialFrame = SKTexture(imageNamed: "player")
        player = SKSpriteNode(texture: initialFrame)
        player.position = CGPoint(x: -170, y: -217)
        player.size = CGSize(width: 100, height: 110)
        
        // Set up physics for the player
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = 2
        player.physicsBody?.contactTestBitMask = 1
        
        addChild(player)
        
        // Load all frames for the running animation
        for i in 1...6 {
            runningFrames.append(SKTexture(imageNamed: "player-run\(i)"))
        }
        
        // Create the running animation action
        let runningAction = SKAction.animate(with: runningFrames, timePerFrame: 0.1)
        player.run(SKAction.repeatForever(runningAction), withKey: runningActionKey)
    }
    
    func setupSwipeGesture(view: SKView) {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpAction))
        swipeUp.direction = .up
        view.addGestureRecognizer(swipeUp)
    }
    
    @objc func swipeUpAction() {
        if !isGameOver{
            jumpPlayer()
        }
    }
    
    func jumpPlayer() {
        if !isPlayerJumping {
            isPlayerJumping = true
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 350))
            player.removeAction(forKey: runningActionKey)  // Stop running animation
            player.texture = SKTexture(imageNamed: "player-jump1")
        }
    }
    //death's animation
    func loadDeathTextures() {
        for i in 1...2 {
            deathFrames.append(SKTexture(imageNamed: "death\(i)"))
        }
    }
    
    //shoot's animation
    func loadShootTextures() {
        for i in 1...6 {
            shootFrames.append(SKTexture(imageNamed: "player-run-shoott\(i)"))
        }
    }
    
    func shootPlayer() {
        if !isPlayerJumping {
            // Rimuovi l'animazione di corsa e cambia la texture del player
            player.removeAction(forKey: runningActionKey)
            player.texture = SKTexture(imageNamed: "player-run-shoott1")
            
            // Crea l'animazione di "shoot"
            let shootAction = SKAction.animate(with: shootFrames, timePerFrame: 0.1)
            
            // Usa la completion handler per tornare all'animazione di corsa dopo l'animazione di "shoot"
            player.run(shootAction) { [weak self] in
                self?.player.texture = SKTexture(imageNamed: "player") // Torna alla texture normale
                let runningAction = SKAction.animate(with: self?.runningFrames ?? [], timePerFrame: 0.1)
                self?.player.run(SKAction.repeatForever(runningAction), withKey: self?.runningActionKey ?? "") // Riprendi l'animazione di corsa
            }
        }
    }


    func playDeathAnimation() {

        player.removeAllActions() // Rimuove tutte le azioni in corso, inclusa l'animazione di corsa
        player.physicsBody?.collisionBitMask &= ~groundNode.physicsBody!.categoryBitMask
        player.zPosition = 3
        
        // Carica le texture di morte
        let deathTexture1 = SKTexture(imageNamed: "death1")
        let deathTexture2 = SKTexture(imageNamed: "death2")
        
        // Crea l'animazione di morte
        let jumpUpAction = SKAction.moveBy(x: 0, y: 300, duration: 0.8)  // Salto verso l'alto
        let changeToDeath1 = SKAction.setTexture(deathTexture1)
        
        // Modifica la durata della caduta per far sì che l'animazione vada oltre il suolo
        let fallDownAction = SKAction.moveBy(x: 0, y:0, duration: 0.8)  // Caduta
        
        let changeToDeath2 = SKAction.setTexture(deathTexture2)
        
        // Combina le azioni per creare l'animazione completa
        let deathAnimation = SKAction.sequence([changeToDeath1, jumpUpAction, changeToDeath2, fallDownAction])
        player.removeAction(forKey: runningActionKey)
        
        // Usa la completion handler per garantire che l'animazione di morte sia terminata prima di eseguire altre azioni
        player.run(deathAnimation) { [weak self] in
            self?.showGameOverScreen()  // Mostra la schermata di game over dopo l'animazione
            self?.canRestart=true
            
        }
        
    }
    
}


//MARK: INTROSCENE
extension GameScene{
    // Funzione di gioco ottimizzata
    func startGame() {
        // Crea il giocatore e altri elementi di gioco
        createPlayer()
        createLoveNode()
        spawnEnemiesPeriodically()
    }
    //animation intro
    func initializeIntroAnimation() {
        for i in 1...61 {
            introAnimationFrames.append(SKTexture(imageNamed: "intro\(i)"))
        }
    }
    
    func playIntroAnimation() {
        let animation = SKAction.animate(with: introAnimationFrames, timePerFrame: 0.007)
        animationNode = SKSpriteNode(texture: introAnimationFrames.first)
        animationNode.position = CGPoint(x: frame.midX, y: frame.midY)
        animationNode.size=CGSize(width: frame.width, height: frame.height)
        animationNode.zPosition = 2
        addChild(animationNode)
        
        animationNode.run(animation) { [weak self] in
            self?.showTapToPlay()
        }
    }
    
    func showTapToPlay() {
        tapToPlayLabel.text = "Tap to Play"
        tapToPlayLabel.fontSize = 40
        tapToPlayLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(tapToPlayLabel)
    }
}

//MARK: GAMEOVER
extension GameScene{
    // Funzione di gioco ottimizzata
    func gameOver() {
        isGameOver = true
        playDeathAnimation()
        
        // Rimuovi le etichette di game over
        gameOverLabel.removeFromParent()
        
        // Mostra "Game Over" e "Tap to Restart"
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)
        
        // Rimuovi tutte le azioni e gli sprite nemici
        self.removeAllActions()
        for enemy in enemies {
            enemy.removeAllActions()
            enemy.removeFromParent()
        }
    }
    
    // Funzione di gioco ottimizzata
      func showGameOverScreen() {
          // Rimuovi etichetta di restart esistente, se presente
          restartLabel.removeFromParent()
          
          // Configura l'etichetta di "Tap to Restart"
          restartLabel.text = "Tap to Restart"
          restartLabel.fontSize = 30
          restartLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
          restartLabel.fontColor = UIColor.black
          
          // Aggiungi l'etichetta con effetto di lampeggiamento
          addChild(restartLabel)
          let fadeOut = SKAction.fadeOut(withDuration: 0.8)
          let fadeIn = SKAction.fadeIn(withDuration: 0.8)
          let blinkSequence = SKAction.sequence([fadeOut, fadeIn])
          let repeatBlink = SKAction.repeatForever(blinkSequence)
          restartLabel.run(repeatBlink)
      }
    
    
    
    
    
    // Funzione di gioco ottimizzata
    func restartGame() {
        // Controlla se è possibile riavviare il gioco
        if canRestart {
            isGameOver = false
            
            // Rimuovi etichette e sprite di game over
            restartLabel.removeFromParent()
            gameOverLabel.removeFromParent()
            
            // Ripristina gli elementi di gioco
            spawnEnemiesPeriodically()
            createPlayer()
            
            canRestart = false
        }
    }
}
