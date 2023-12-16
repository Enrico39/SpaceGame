//
//  GameScene.swift
//  test game
//
//  Created by Enrico Madonna(Beniamino Nardones wife) on 07/12/23.
//
import SpriteKit
import GameplayKit
import SwiftUI
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    @AppStorage("HighScore") var highScore: Int = 0
    let highScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var score: Int = 0
    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    let gameOverScoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    var startScore:Bool = false
    
    
    let projectileCategory: UInt32 = 8

    var groundNode: SKSpriteNode!
    var player: SKSpriteNode!
    let backgroundSpeed: CGFloat = 100.0
    var lastUpdateTime: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    var isPlayerJumping = false
    let runningActionKey = "runningAction"
    var runningFrames: [SKTexture] = []
    var shootFrames: [SKTexture] = []
    var gameOverNode: SKSpriteNode!
    let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
    let restartLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    var isGameOver = false
    var canShot = false

    
    
    
    let enemyCategory: UInt32 = 4
    var enemies: [SKSpriteNode] = []
    var introAnimationFrames: [SKTexture] = []
    let tapToPlayLabel = SKLabelNode(fontNamed: "Chalkduster")
    var animationNode: SKSpriteNode!
    var backgroundFrames: [SKTexture] = []
    var backgroundFrames2: [SKTexture] = []
    let obstacleCategory: UInt32 = 16

    var scrollingBackground: SKSpriteNode!
    var scrollingBackground1: SKSpriteNode!
    var scrollingBackground2: SKSpriteNode!
    var canRestart:Bool = false
    var deathFrames: [SKTexture] = []
    
    var moonGround1: SKSpriteNode!
    var moonGround2: SKSpriteNode!
    var moonGroundSpeed: CGFloat = 5.0
    var obstacle: SKSpriteNode!

    override func didMove(to view: SKView) {
         // Imposta il delegate per la gestione dei contatti fisici
         self.physicsWorld.contactDelegate = self
         
         // Inizializza e avvia l'animazione introduttiva
         initializeIntroAnimation()
         playIntroAnimation()
         showHighScore()
         // Configura la gesture di swipe
         setupSwipeGesture(view: view)
         
         // Crea il terreno di gioco
         createGround()
         
         // Carica le texture degli sfondi
         loadBackgroundTextures()
         loadBackgroundTextures2()
         
         // Carica le texture per l'animazione di "shoot"
         loadShootTextures()
         
         // Crea gli sfondi scorrevoli
         createScrollingBackgrounds()
         
         // Crea i terreni lunari
         createMoonGrounds()
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
                 highScoreLabel.removeFromParent()
                startGame()
                 

            } else {
                // Esegui l'animazione di "shoot"
           
            }
        }
    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            _ = touch.location(in: self)
            // Qui puoi gestire cosa accade quando il tocco termina
            if !isPlayerJumping && !isGameOver && canShot{
                shootPlayer()
            }
            // Ad esempio, puoi rilevare se il tocco è terminato su un nodo specifico, ecc.
        }
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
        _ = player as SKNode
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
        
        if (contact.bodyA.categoryBitMask == player.physicsBody?.categoryBitMask && contact.bodyB.categoryBitMask == obstacleCategory) ||
            (contact.bodyA.categoryBitMask == obstacleCategory && contact.bodyB.categoryBitMask == player.physicsBody?.categoryBitMask) {
            gameOver()
        }
        
        if !isGameOver && !isPlayerJumping {
            if player.action(forKey: runningActionKey) == nil {
                let runningAction = SKAction.animate(with: runningFrames, timePerFrame: 0.1)
                player.run(SKAction.repeatForever(runningAction), withKey: runningActionKey)
            }
        }  
        
        // Collision between projectile and enemy
        if (contact.bodyA.categoryBitMask == projectileCategory && contact.bodyB.categoryBitMask == enemyCategory) ||
           (contact.bodyB.categoryBitMask == projectileCategory && contact.bodyA.categoryBitMask == enemyCategory) {
            // Remove both nodes
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
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
            updateBackgrounds()
           // updateBackgroundPosition(scrollingBackground1)
          //  updateBackgroundPosition(scrollingBackground2)
            updateBackgroundPosition(moonGround1)
            updateBackgroundPosition(moonGround2)
            showScore()
            if startScore==true{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.score+=1
                }
            }

        }
    }
    
    
  
}

// MARK: OBSTACLES
extension GameScene {
    func spawnObstaclesPeriodically() {
        let spawn = SKAction.run { [weak self] in
            self?.createObstacle()
        }
        let delay = SKAction.wait(forDuration: 3.0, withRange: 1.0)
        let spawnSequence = SKAction.sequence([spawn, delay])
        run(SKAction.repeatForever(spawnSequence))
    }
    
    func createObstacle() {
        let obst = SKSpriteNode(imageNamed: "obstacle")
        obst.position = CGPoint(x: 300, y: -217)
        obst.size = CGSize(width: 60, height: 130)
        obst.xScale = -1
//        
//        var walkFrames: [SKTexture] = []
//        for i in 1...6 {
//            walkFrames.append(SKTexture(imageNamed: "alien\(i)"))
//        }
//        let walkAction = SKAction.animate(with: walkFrames, timePerFrame: 0.1)
//        enemy.run(SKAction.repeatForever(walkAction))
        
        obst.physicsBody = SKPhysicsBody(texture: obst.texture!, size: obst.size)
        obst.physicsBody?.isDynamic = true
        obst.physicsBody?.allowsRotation = false
        obst.physicsBody?.categoryBitMask = obstacleCategory
        obst.physicsBody?.contactTestBitMask = player.physicsBody!.categoryBitMask | groundNode.physicsBody!.categoryBitMask
        obst.physicsBody?.collisionBitMask = groundNode.physicsBody!.categoryBitMask
        obst.zPosition = 12
        
        let moveAction = SKAction.moveTo(x: -500, duration: 2.0)
        let removeAction = SKAction.removeFromParent()
        obst.run(SKAction.sequence([moveAction, removeAction]))
        
        addChild(obst)
        enemies.append(obst)
    }
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
        let loveNode = SKSpriteNode(imageNamed: "life-export9")
        loveNode.position = CGPoint(x: 30, y: 500)
       // loveNode.size = CGSize(width: 500, height: 300)
        loveNode.zPosition = 1
        addChild(loveNode)
        
        var lifeAnimation: [SKTexture] = []
        for i in stride(from: 9, to: 0, by: -1) {
           
            lifeAnimation.append(SKTexture(imageNamed: "life-export\(i)"))
        }
        
        let moveLife = SKAction.animate(with: lifeAnimation, timePerFrame: 3)
        loveNode.run(moveLife)
        
      
        
      
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
            shootFrames.append(SKTexture(imageNamed: "player-shoot\(i)"))
        }
    }
    
    func shootPlayer() {
        if !isPlayerJumping {
            // Rimuovi l'animazione di corsa e cambia la texture del player
            player.removeAction(forKey: runningActionKey)
            player.texture = SKTexture(imageNamed: "player-shoot1")
            
            // Crea l'animazione di "shoot"
            let shootAction = SKAction.animate(with: shootFrames, timePerFrame: 0.1)
            
            // Usa la completion handler per tornare all'animazione di corsa dopo l'animazione di "shoot"
            player.run(shootAction) { [weak self] in
                self?.player.texture = SKTexture(imageNamed: "player") // Torna alla texture normale
                let runningAction = SKAction.animate(with: self?.runningFrames ?? [], timePerFrame: 0.1)
                self?.player.run(SKAction.repeatForever(runningAction), withKey: self?.runningActionKey ?? "") // Riprendi l'animazione di corsa
            }
            createProjectile()
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
        player.zPosition=6
        // Usa la completion handler per garantire che l'animazione di morte sia terminata prima di eseguire altre azioni
        player.run(deathAnimation) { [weak self] in
            self?.showGameOverScreen()  // Mostra la schermata di game over dopo l'animazione
            self?.canRestart=true
            
        }
        
    }
    
}


// MARK: SHOOTING SYSTEM
extension GameScene{

    func createProjectile() {
        let projectile = SKSpriteNode(imageNamed: "proiettile")
        projectile.position = CGPoint(x: -100, y: -217)
        projectile.size=CGSize(width: 30, height: 30)

        projectile.physicsBody = SKPhysicsBody(texture: projectile.texture!, size: projectile.size)

        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = projectileCategory
        projectile.physicsBody?.contactTestBitMask = enemyCategory
        projectile.physicsBody?.collisionBitMask = 0
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        addChild(projectile)
        projectile.physicsBody?.affectedByGravity = false
        let moveAction = SKAction.moveBy(x: 300, y: 0, duration: 2.0)
        let removeAction = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([moveAction, removeAction]))
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
        moonGroundNode.size = CGSize(width: 1900, height:410)  // Modifica la dimensione in base alle tue esigenze
        moonGroundNode.zPosition = 5
        return moonGroundNode
    }
    
    func createMoonGrounds() {
        moonGround1 = createMoonGroundNode(imageName: "moon3")
        moonGround2 = createMoonGroundNode(imageName: "moon4")
         moonGround2.position = CGPoint(x: moonGround1.position.x + moonGround1.size.width, y: moonGround1.position.y)

         addChild(moonGround1)
         addChild(moonGround2)
     }

}

 // MARK: BACKGROUND
extension GameScene {
    
    func updateBackgroundPosition(_ background: SKSpriteNode) {
        background.position = CGPoint(x: background.position.x - moonGroundSpeed, y: background.position.y)
        
        if background.position.x <= -background.size.width {
            background.position = CGPoint(x: background.size.width, y: background.position.y)
        }
    }
    
    // Carica le texture degli sfondi
    func loadBackgroundTextures() {
        for i in 1...150 {
            backgroundFrames.append(SKTexture(imageNamed: "planets\(i)"))
        }
    }
    
    func loadBackgroundTextures2() {
        for i in 1...60 {
            backgroundFrames2.append(SKTexture(imageNamed: "planets_2_\(i)"))
        }
    }
    
    func createScrollingBackgrounds() {
        scrollingBackground1 = createBackgroundNode(texture: backgroundFrames, yOffset: 100)
        scrollingBackground2 = createBackgroundNode(texture: backgroundFrames2, yOffset: 100)
        scrollingBackground2.position = CGPoint(x: scrollingBackground1.position.x + scrollingBackground1.size.width, y: scrollingBackground1.position.y)
        
        addChild(scrollingBackground1)
        addChild(scrollingBackground2)
    }
    
    // Funzione di creazione ottimizzata per gli sfondi di gioco
    func createBackgroundNode(texture: [SKTexture], yOffset: CGFloat) -> SKSpriteNode {
        let backgroundNode = SKSpriteNode(texture: texture.first)
        backgroundNode.position = CGPoint(x: frame.midX, y: groundNode.position.y + groundNode.size.height / 2 + backgroundNode.size.height / 2 + yOffset)
        backgroundNode.size = CGSize(width: 3000, height: 1000)
        backgroundNode.zPosition = -1
        
        let backgroundAnimation = SKAction.animate(with: texture, timePerFrame: 0.12)
        let endlessAnimation = SKAction.repeatForever(backgroundAnimation)
        backgroundNode.run(endlessAnimation)
        
        return backgroundNode
    }
    
    // Chiamare questa funzione nell'override della funzione update per aggiornare la posizione degli sfondi
    func updateBackgrounds() {
        if !isGameOver {
            updateBackgroundPosition(scrollingBackground1)
            updateBackgroundPosition(scrollingBackground2)
            
            // Rimuovi gli sfondi scorrevoli fuori dallo schermo
            if scrollingBackground1.position.x < -scrollingBackground1.size.width {
                scrollingBackground1.removeFromParent()
                scrollingBackground1 = createBackgroundNode(texture: backgroundFrames, yOffset: 100)
                addChild(scrollingBackground1)
            }
            if scrollingBackground2.position.x < -scrollingBackground2.size.width {
                scrollingBackground2.removeFromParent()
                scrollingBackground2 = createBackgroundNode(texture: backgroundFrames2, yOffset: 100)
                scrollingBackground2.position = CGPoint(x: scrollingBackground1.position.x + scrollingBackground1.size.width, y: scrollingBackground1.position.y)
                addChild(scrollingBackground2)
            }
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
        spawnObstaclesPeriodically()
        startScore=true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.canShot = true
            // Qui puoi anche aggiungere altro codice che vuoi eseguire dopo che la variabile è stata impostata su true
        }
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
        animationNode.zPosition = 20
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
        canShot = false
        isGameOver = true
        playDeathAnimation()
        updateHighScore()
//        // Rimuovi le etichette di game over
//        gameOverLabel.removeFromParent()
//        
//        // Mostra "Game Over" e "Tap to Restart"
//        gameOverLabel.text = "Game Over"
//        gameOverLabel.fontSize = 40
//        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
//        addChild(gameOverLabel)
        
        
        if gameOverNode?.parent != nil {
            gameOverNode.removeFromParent()
        }
        
           gameOverNode = SKSpriteNode(imageNamed: "gameOver")
                gameOverNode.size = CGSize(width: 500, height: 500)
                gameOverNode.position = CGPoint(x: 10, y: 30)
                addChild(gameOverNode)
        
        
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
//            gameOverLabel.removeFromParent()
            gameOverNode.removeFromParent()

            // Ripristina gli elementi di gioco
            spawnEnemiesPeriodically()
            createPlayer()
            spawnObstaclesPeriodically()
            canRestart = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.canShot = true
                // Qui puoi anche aggiungere altro codice che vuoi eseguire dopo che la variabile è stata impostata su true
            }
            gameOverScoreLabel.removeFromParent()
            score=0

        }
    }
}

//MARK: SCORE SYSTEM

extension GameScene{
    
    func showHighScore(){
        highScoreLabel.text = "Highscore: \(highScore)"
        highScoreLabel.fontSize = 50
        highScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY - 250)
        highScoreLabel.fontColor = UIColor.black
        highScoreLabel.zPosition=25
        addChild(highScoreLabel)
    }
    
    func showScore(){
        scoreLabel.text = "Score: \(score)"
        scoreLabel.fontSize = 30
        scoreLabel.position = CGPoint(x: frame.midX+200, y: frame.midY + 400)
        scoreLabel.fontColor = UIColor.black
        scoreLabel.zPosition=19
         
            
            if scoreLabel.parent != nil {
//                 print("tapToPlayLabel è stato aggiunto alla scena.")
            } else {
                addChild(scoreLabel)

            }
    }
    
    func updateHighScore(){
        if score > highScore{
            highScore=score
//            gameOverScoreLabel.text = "New Highscore: \(highScore)"
//            print("dd")

        }
        else{
//            gameOverScoreLabel.text = "Your Score: \(score)"
        }
                
        
        gameOverScoreLabel.text = "Highscore: \(highScore)\n Your score \(score)"
         gameOverScoreLabel.fontSize = 30
        gameOverScoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverScoreLabel.fontColor = UIColor.black
        gameOverScoreLabel.zPosition=25
        gameOverScoreLabel.removeFromParent()
        addChild(gameOverScoreLabel)
    }
    
    
}
