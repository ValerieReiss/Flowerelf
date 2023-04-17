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
    
    var scoreLabel = SKLabelNode()
    var score = 0
    
    var gameOverLabel = SKLabelNode()
    var TapTap = SKLabelNode()
    
    var timer2 = Timer()
    var gameOver = false
     
    // Enum to handle collision. Elf vs Object = 1 + 2 =3 for example
     
    enum ColliderType: UInt32
    {
        case Elf = 1
        case Object = 2
        case Enemy = 4
        case Water = 8
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if (gameOver==false)
        {
            if (contactMask == 12)
                {
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                score += 1
                print("hit enemy")
                }
      
            else if (contactMask == 10)
            {
                score += 1
                print("water ground")
            }
            else
                {
                self.speed = 0
                gameOver = true
                timer2.invalidate()
                gameOverLabel.fontName = "Chalkduster"
                let GameOverBackground = SKSpriteNode(imageNamed: "gameOverBack.png")
                GameOverBackground.size = CGSize(width: 1290, height: 645)
                GameOverBackground.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                GameOverBackground.zPosition = 1
                self.addChild(GameOverBackground)
                
                scoreLabel.fontSize = 100
                scoreLabel.fontName = "Chalkduster"
                scoreLabel.position = CGPoint(x : self.frame.minX + 400 , y: self.frame.minY + 800)
                scoreLabel.zPosition = 2
                scoreLabel.text = "\(score)"
                gameOverLabel.fontSize = 100
                gameOverLabel.text = "PLAY AGAIN"
                gameOverLabel.position = CGPoint(x : self.frame.midX, y: self.frame.midY + 400)
                gameOverLabel.zPosition = 2
                self.addChild(gameOverLabel)
                }
        }
    }
 
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.setUpgame()
    }
    
    func setUpgame()
    {
        var ArrayName : [String] = []
        var randomIndexBackground: Int = 0
        let backgroundArray = ["background0.png", "background1.png", "background2.png", "background4.png"]
        randomIndexBackground = Int(arc4random_uniform(4))
        let bgTexture = SKTexture(imageNamed: backgroundArray[randomIndexBackground])
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
        var lives = 10
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontSize = 100
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPoint(x: self.frame.midX + 400, y: self.frame.midY + 800)
        self.addChild(scoreLabel)
        
        timer2 = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.makeEnemy), userInfo: nil, repeats: true)
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic=false
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(sound)
        TapTap.removeFromParent()
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
        print("\(score)")
    }
    
    
}
