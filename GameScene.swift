//
//  GameScene.swift
//  LitteFlowerElf
//
//  Created by Valerie on 17.04.23.
//

import SpriteKit
import GameplayKit
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let sound = SKAction.playSoundFileNamed("sfx_swooshing.wav", waitForCompletion: false)
    var elf  = SKSpriteNode()
    var bg = SKSpriteNode()
    var water = SKSpriteNode()
    var Enemy = SKSpriteNode()
    var Flower = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    var score = 0
    
    var scoreHearts = SKLabelNode()
    var hearts = SKSpriteNode()
    var playerHearts = 20
    
    var gameOverLabel = SKLabelNode()
    
    var timer1 = Timer()
    var timer2 = Timer()
    var gameOver = false
    var won = false
     
    // Enum to handle collision. Elf vs Object = 1 + 2 =3 for example
     
    enum ColliderType: UInt32
    {
        case Elf = 1
        case Object = 2
        case Enemy = 4
        case Water = 8
        case Flower = 16
    }
    
    func setUpgame()
    {
        var ArrayName : [String] = []
        //var randomIndexBackground: Int = 0
        //let backgroundArray = ["background1"]
        //randomIndexBackground = Int(arc4random_uniform(4))
        let bgTexture = SKTexture(imageNamed: "background1")
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0),duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        var i: CGFloat = 0
        while i<3
        {
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.run(moveBGForever)
            bg.zPosition = -2
            self.addChild(bg)
            i += 1
        }
        var randomIndexElf: Int = 0
        //randomIndexElf = Int(arc4random_uniform(2))
        if randomIndexElf == 0
        {
            ArrayName = ["elf1", "elf2", "elf3", "elf4"]
        }
        /*else
        {
            ArrayName = ["D2FLY_000.png", "D2FLY_001.png", "D2FLY_004.png", "D2ATTACK_005.png"]
            
        }*/
        let elfTexture = SKTexture(imageNamed: ArrayName[0])
        let elfTexture2 = SKTexture(imageNamed: ArrayName[1])
        let elfTexture3 = SKTexture(imageNamed: ArrayName[2])
        let elfTexture4 = SKTexture(imageNamed: ArrayName[3])
        let animation = SKAction.animate(with: [elfTexture, elfTexture2, elfTexture3, elfTexture4], timePerFrame: 0.08)
        let makeElfFlap = SKAction.repeatForever(animation)
        elf = SKSpriteNode(texture: elfTexture)
        elf.position = CGPoint(x: -400, y: self.frame.midY)
        elf.physicsBody = SKPhysicsBody(circleOfRadius: elfTexture.size().height/2)
        elf.physicsBody!.isDynamic = false
        elf.physicsBody?.affectedByGravity = true
        elf.run(makeElfFlap)
        elf.setScale(0.5)
        elf.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        elf.physicsBody!.categoryBitMask = ColliderType.Elf.rawValue
        elf.physicsBody!.collisionBitMask = ColliderType.Elf.rawValue
        self.addChild(elf)
        
        var playerHearts = 20
        let hearts = SKSpriteNode(imageNamed: "objectHeart.jpg")
        hearts.name = "heart"
        hearts.position = CGPoint(x: self.frame.midX - 450, y: self.frame.maxY - 200)
        hearts.setScale(2)
        hearts.zPosition = 5
        addChild(hearts)
        scoreHearts = SKLabelNode(fontNamed: "Bradley Hand")
        scoreHearts.fontSize = 120
        scoreHearts.text = "\(playerHearts)"
        scoreHearts.position = CGPoint(x: self.frame.midX - 320, y: self.frame.maxY - 200)
        addChild(scoreHearts)
        
        var score = 0
        let flower = SKSpriteNode(imageNamed: "objectHeart.jpg")
        flower.name = "flower"
        flower.position = CGPoint(x: self.frame.midX - 450, y: self.frame.maxY - 300)
        flower.setScale(2)
        flower.zPosition = 5
        addChild(flower)
        scoreLabel = SKLabelNode(fontNamed: "Bradley Hand")
        scoreLabel.fontSize = 120
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPoint(x: self.frame.midX - 320, y: self.frame.maxY - 300)
        addChild(scoreLabel)
        
        timer2 = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.makeEnemy), userInfo: nil, repeats: true)
        timer1 = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.makeFlower), userInfo: nil, repeats: true)
        
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic=false
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if (gameOver==false)
        {
            if (contactMask == 5)
                {
                playerHearts -= 1
                Enemy.removeFromParent()
                if playerHearts == 0 { gameover() }
                }
            else if (contactMask == 3)
                {
                print("touched ground")
                gameover()
                }
            else if (contactMask == 12)
                {
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                score += 1
                print("hit enemy")
                }
      
            else if (contactMask == 24)
            {
                score += 1
                print("blume gegossen")
                if score == 20 {
                    won = true
                    gameover() }
            }
            
            else
            {
               print("hääääää?")
            }
        }
    }
 
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.setUpgame()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(sound)
        if (gameOver == false) {
            elf.physicsBody!.isDynamic = true
            elf.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            elf.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 3000))
            makeWater()
            }
        else
            {
            gameOver = false
            score = 0
            self.speed = 1
            self.removeAllChildren()
            setUpgame()
            }
    }
   
    override func update(_ currentTime: TimeInterval) {
        scoreHearts.text = "\(playerHearts)"
        scoreLabel.text = "\(score)"
    }
    
    func gameover(){
        if won == true {
            if let bubbles = SKEmitterNode(fileNamed: "particle-won"){
                        bubbles.particleTexture = SKTexture(imageNamed: "particleHeart")
                bubbles.position = CGPoint(x: 0.0, y: 0.0)
                        bubbles.zPosition = 10
                        addChild(bubbles)}
            won = false
        }
        self.speed = 0
        gameOver = true
        timer2.invalidate()
        gameOverLabel.fontName = "Chalkduster"
        let GameOverBackground = SKSpriteNode(imageNamed: "gameOverBack.png")
        GameOverBackground.size = CGSize(width: 1290, height: 645)
        GameOverBackground.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        GameOverBackground.zPosition = 1
        self.addChild(GameOverBackground)
        playerHearts = 20
        gameOverLabel.fontSize = 100
        gameOverLabel.text = "PLAY AGAIN"
        gameOverLabel.position = CGPoint(x : self.frame.midX, y: self.frame.midY + 400)
        gameOverLabel.zPosition = 2
        self.addChild(gameOverLabel)
    }
    
    @objc func makeFlower()
     {
         let FlowerActualY = arc4random() % UInt32(self.frame.height/2)
         //let FlowerY = arc4random() % UInt32(self.frame.height/2)
         let FlowerTexture = SKTexture(imageNamed: "objectFlower1.png")
         //Make flapping butterfly
         /*let objectButterfly2  = SKTexture(imageNamed: "objectButterfly2.png")
         let objectButterfly3 = SKTexture(imageNamed: "objectButterfly3.png")
         let animation = SKAction.animate(with: [EnemyTexture, objectButterfly2, objectButterfly3], timePerFrame: 0.08)*/
         let moveFlower = SKAction.move(to: CGPoint(x: -1000, y: 200), duration: 6)
         //let makeBUtterflyFlap = SKAction.repeatForever(animation)
         
         Flower = SKSpriteNode(texture: FlowerTexture)
        /* if FlowerY < UInt32(self.frame.height/4)
         { FlowerActualY = -2 * CGFloat(FlowerY) }
         else
         { FlowerActualY = CGFloat(FlowerY) }*/
         
         Flower.position = CGPoint(x: self.frame.width, y: CGFloat(FlowerActualY))
         Flower.run(moveFlower)
         //Enemy.run(makeButterflyFlap)
         Flower.physicsBody = SKPhysicsBody(rectangleOf: FlowerTexture.size())
         Flower.physicsBody!.isDynamic = true
         Flower.physicsBody!.contactTestBitMask = ColliderType.Water.rawValue
         Flower.physicsBody!.categoryBitMask = ColliderType.Flower.rawValue
         Flower.physicsBody!.collisionBitMask = ColliderType.Flower.rawValue
         Flower.setScale(0.5)
         self.addChild(Flower)

     }
    
    @objc func makeWater() {
        let waterTexture = SKTexture(imageNamed: "objectWaterdrop")
        water = SKSpriteNode(texture: waterTexture)
        water.position = CGPoint(x: elf.position.x, y: elf.position.y)
        let moveWaterForward = SKAction.move(by: CGVector(dx: 100, dy: 0), duration: 1)
        water.run(moveWaterForward)
        water.physicsBody = SKPhysicsBody(rectangleOf: waterTexture.size())
        water.physicsBody!.isDynamic = true
        water.physicsBody?.affectedByGravity = true
        water.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        water.physicsBody!.categoryBitMask = ColliderType.Water.rawValue
        water.physicsBody!.collisionBitMask = ColliderType.Water.rawValue
        self.addChild(water)
        
    }
    
   @objc func makeEnemy()
    {
        var EnemyActualY: CGFloat = 0.0
        let EnemyY = arc4random() % UInt32(self.frame.height/2)
        let EnemyTexture = SKTexture(imageNamed: "objectButterfly1.png")
        //Make flapping butterfly
        /*let objectButterfly2  = SKTexture(imageNamed: "objectButterfly2.png")
        let objectButterfly3 = SKTexture(imageNamed: "objectButterfly3.png")
        let animation = SKAction.animate(with: [EnemyTexture, objectButterfly2, objectButterfly3], timePerFrame: 0.08)*/
        let moveButterfly = SKAction.move(to: CGPoint(x: -1000, y: 200), duration: 6)
        //let makeBUtterflyFlap = SKAction.repeatForever(animation)
        
        Enemy = SKSpriteNode(texture: EnemyTexture)
        if EnemyY < UInt32(self.frame.height/4)
        { EnemyActualY = -2 * CGFloat(EnemyY) }
        else
        { EnemyActualY = CGFloat(EnemyY) }
        
        Enemy.position = CGPoint(x: self.frame.width, y: EnemyActualY)
        Enemy.run(moveButterfly)
        //Enemy.run(makeButterflyFlap)
        Enemy.physicsBody = SKPhysicsBody(rectangleOf: EnemyTexture.size())
        Enemy.physicsBody!.isDynamic = true
        Enemy.physicsBody!.contactTestBitMask = ColliderType.Elf.rawValue
        Enemy.physicsBody!.categoryBitMask = ColliderType.Enemy.rawValue
        Enemy.physicsBody!.collisionBitMask = ColliderType.Enemy.rawValue
        Enemy.setScale(0.5)
        self.addChild(Enemy)

    }
}
