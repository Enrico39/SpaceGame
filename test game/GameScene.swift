//
//  GameScene.swift
//  test game
//
//  Created by Enrico Madonna on 07/12/23.
//
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var groundNode: SKSpriteNode!
    var player: SKSpriteNode!

    let backgroundSpeed: CGFloat = 100.0
    var lastUpdateTime: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    var isPlayerJumping = false
    let runningActionKey = "runningAction"
    var runningFrames: [SKTexture] = []
    let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
    let restartLabel = SKLabelNode(fontNamed: "Chalkduster")
    var isGameOver = false
    let enemyCategory: UInt32 = 4
    var enemies: [SKSpriteNode] = []
    var introAnimationFrames: [SKTexture] = []
    let tapToPlayLabel = SKLabelNode(fontNamed: "Chalkduster")
    var animationNode: SKSpriteNode!
    var backgroundFrames: [SKTexture] = []
        var scrollingBackground: SKSpriteNode!
    var scrollingBackground1: SKSpriteNode!
    var scrollingBackground2: SKSpriteNode!
    
    
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        initializeIntroAnimation()
        playIntroAnimation()
        
        setupSwipeGesture(view: view)
 
        createGround()
        loadBackgroundTextures()
        createScrollingBackgrounds()
    }
    
    func loadBackgroundTextures() {
        for i in 1...306 {
            backgroundFrames.append(SKTexture(imageNamed: "planets\(i)"))
        }
    }
    func createScrollingBackgrounds() {
          scrollingBackground1 = createBackgroundNode()
          scrollingBackground2 = createBackgroundNode()
          scrollingBackground2.position = CGPoint(x: scrollingBackground1.position.x + scrollingBackground1.size.width, y: scrollingBackground1.position.y)

          addChild(scrollingBackground1)
          addChild(scrollingBackground2)
      }
    func createScrollingBackground() {
        loadBackgroundTextures()
        let backgroundAnimation = SKAction.animate(with: backgroundFrames, timePerFrame: 0.03)
        let endlessAnimation = SKAction.repeatForever(backgroundAnimation)

        // Crea il primo nodo di sfondo
        let scrollingBackground1 = createBackgroundNode()
        scrollingBackground1.run(endlessAnimation)
        
        // Crea il secondo nodo di sfondo
        let scrollingBackground2 = createBackgroundNode()
        scrollingBackground2.position = CGPoint(x: scrollingBackground1.position.x + scrollingBackground1.size.width, y: scrollingBackground1.position.y)
        scrollingBackground2.run(endlessAnimation)

        let moveLeft = SKAction.moveBy(x: -scrollingBackground1.size.width * 2, y: 0, duration: 20)
        let resetPosition = SKAction.run {
            scrollingBackground1.position = CGPoint(x: scrollingBackground1.position.x + scrollingBackground1.size.width * 2, y: scrollingBackground1.position.y)
            scrollingBackground2.position = CGPoint(x: scrollingBackground2.position.x + scrollingBackground2.size.width * 2, y: scrollingBackground2.position.y)
        }
        let moveSequence = SKAction.sequence([moveLeft, resetPosition])
        let moveForever = SKAction.repeatForever(moveSequence)

        scrollingBackground1.run(moveForever)
        scrollingBackground2.run(moveForever)

        addChild(scrollingBackground1)
        addChild(scrollingBackground2)
    }

    func createBackgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode(texture: backgroundFrames.first)
        let yPos = groundNode.position.y + groundNode.size.height / 2 + backgroundNode.size.height / 2
        backgroundNode.position = CGPoint(x: frame.midX, y: yPos + 100)
        backgroundNode.size = CGSize(width: 3000, height: 1000)
        backgroundNode.zPosition = -1

        // Aggiungi l'animazione dei pianeti
        let backgroundAnimation = SKAction.animate(with: backgroundFrames, timePerFrame: 0.03)
        let endlessAnimation = SKAction.repeatForever(backgroundAnimation)
        backgroundNode.run(endlessAnimation)

        return backgroundNode
    }


    
    func initializeIntroAnimation() {
        for i in 1...61 {
            introAnimationFrames.append(SKTexture(imageNamed: "intro\(i)"))
        }
    }
    
    func playIntroAnimation() {
        let animation = SKAction.animate(with: introAnimationFrames, timePerFrame: 0.01)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGameOver {
            restartGame()
        } else {
            if tapToPlayLabel.parent != nil {
                tapToPlayLabel.removeFromParent()
                animationNode.removeFromParent()
                startGame()
            } else {
                // Handle other touch events, like jumping
            }
        }
    }
    
    func startGame() {
        
        createPlayer()
        createLoveNode()
        spawnEnemiesPeriodically()
    }
    
    func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        groundNode = SKSpriteNode(texture: groundTexture)
        groundNode.position = CGPoint(x: frame.midX, y: frame.minY + groundNode.size.height / 2)
        addChild(groundNode)
        
        groundNode.physicsBody = SKPhysicsBody(rectangleOf: groundNode.size)
        groundNode.physicsBody?.isDynamic = false
        groundNode.physicsBody?.categoryBitMask = 1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let playerNode = player as SKNode
        let groundNode = groundNode as SKNode
        
        if (contact.bodyA.categoryBitMask == player.physicsBody?.categoryBitMask && contact.bodyB.categoryBitMask == groundNode.physicsBody?.categoryBitMask) ||
            (contact.bodyA.categoryBitMask == groundNode.physicsBody?.categoryBitMask && contact.bodyB.categoryBitMask == player.physicsBody?.categoryBitMask) {
            isPlayerJumping = false
            if player.action(forKey: runningActionKey) == nil {
                let runningAction = SKAction.animate(with: runningFrames, timePerFrame: 0.1)
                player.run(SKAction.repeatForever(runningAction), withKey: runningActionKey)
            }
        }
        
        if (contact.bodyA.categoryBitMask == player.physicsBody?.categoryBitMask && contact.bodyB.categoryBitMask == enemyCategory) ||
            (contact.bodyA.categoryBitMask == enemyCategory && contact.bodyB.categoryBitMask == player.physicsBody?.categoryBitMask) {
            gameOver()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            deltaTime = currentTime - lastUpdateTime
        } else {
            deltaTime = 0
        }
        lastUpdateTime = currentTime
        
 
        if isPlayerJumping {
            if let velocity = player.physicsBody?.velocity.dy, velocity < 0 {
                player.texture = SKTexture(imageNamed: "player-jump2")
            }
        }
        
        updateBackgroundPosition(scrollingBackground1)
            updateBackgroundPosition(scrollingBackground2)
    }
    
    func updateBackgroundPosition(_ background: SKSpriteNode) {
        // Sposta lo sfondo verso sinistra
        background.position = CGPoint(x: background.position.x - 5, y: background.position.y)

        // Se lo sfondo esce completamente dallo schermo, riposizionalo
        if background.position.x <= -background.size.width {
            background.position = CGPoint(x: background.size.width, y: background.position.y)
        }
    }
    
    func createLoveNode() {
        let loveNode = SKSpriteNode(imageNamed: "love")
        loveNode.position = CGPoint(x: 0, y: 500)
        loveNode.size = CGSize(width: 400, height: 150)
        loveNode.zPosition = 1
        addChild(loveNode)
    }
    
    func gameOver() {
        isGameOver = true
        gameOverLabel.removeFromParent()
        
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 40
        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(gameOverLabel)
        
        restartLabel.removeFromParent()
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 30
        restartLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        addChild(restartLabel)
        
        self.removeAllActions()
        for enemy in enemies {
            enemy.removeAllActions()
        }
        player.removeAllActions()
    }
    
    func restartGame() {
        isGameOver = false
        restartLabel.removeFromParent()
        // Restart any necessary game actions or animations
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
            let enemy = SKSpriteNode(imageNamed: "skeleton-walk1")
            enemy.position = CGPoint(x: 300, y: 217)
            enemy.size = CGSize(width: 60, height: 60)
            enemy.xScale = -1

            var walkFrames: [SKTexture] = []
            for i in 1...8 {
                walkFrames.append(SKTexture(imageNamed: "skeleton-walk\(i)"))
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

            let moveAction = SKAction.moveTo(x: -300, duration: 3.0)
            let removeAction = SKAction.removeFromParent()
            enemy.run(SKAction.sequence([moveAction, removeAction]))

            addChild(enemy)
            enemies.append(enemy)
        }
    }

// MARK: PLAYER
extension GameScene{
    
    func createPlayer() {
        // Load the first frame to initialize the player
        let initialFrame = SKTexture(imageNamed: "player")
        player = SKSpriteNode(texture: initialFrame)
        player.position = CGPoint(x: -170, y: -217)
        player.size = CGSize(width: 100, height: 100)

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
        jumpPlayer()
    }

    func jumpPlayer() {
        if !isPlayerJumping {
            isPlayerJumping = true
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 120))
            player.removeAction(forKey: runningActionKey)  // Stop running animation
            player.texture = SKTexture(imageNamed: "player-jump1")
        }
    }
}
