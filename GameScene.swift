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
    var Waterelf = SKSpriteNode()
    var Butterflyelf = SKSpriteNode()
    var bg = SKSpriteNode()
    var water = SKSpriteNode()
    var Enemy = SKSpriteNode()
    var Flower = SKSpriteNode()
    
    var scoreLabel = SKLabelNode()
    var score = 0
    
    var scoreHearts = SKLabelNode()
    var hearts = SKSpriteNode()
    var playerHearts = 0
    
    var gameOverLabel = SKLabelNode()
    
    var timer1 = Timer()
    var timer2 = Timer()
    
    var gameOver = false
    var won = false
    var indexElf = Int()
    var elfTimer = Timer()
     
    enum ColliderType: UInt32
    {
        case Elf = 1
        case Object = 2
        case Enemy = 4
        case Water = 8
        case Flower = 16
        case Waterelf = 32
        case Butterflyelf = 64
    }
    
    func setUpgame()
    {
        var ArrayName : [String] = []
        
        var randomIndexBackground: Int = 0
        let backgroundArray = ["background1", "background2", "background3", "background4"]
        randomIndexBackground = Int(arc4random_uniform(4))
        let bgTexture = SKTexture(imageNamed: backgroundArray[randomIndexBackground])
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 14)
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
        if randomIndexElf == 0
        {
            ArrayName = ["elf1", "elf2", "elf3", "elf4"]
        }
        let elfTexture = SKTexture(imageNamed: ArrayName[0])
        let elfTexture2 = SKTexture(imageNamed: ArrayName[1])
        let elfTexture3 = SKTexture(imageNamed: ArrayName[2])
        let elfTexture4 = SKTexture(imageNamed: ArrayName[3])
        let animation = SKAction.animate(with: [elfTexture, elfTexture2, elfTexture3, elfTexture4], timePerFrame: 0.08)
        let makeElfFlap = SKAction.repeatForever(animation)
        elf = SKSpriteNode(texture: elfTexture)
        elf.position = CGPoint(x: -350, y: self.frame.midY)
        elf.physicsBody = SKPhysicsBody(circleOfRadius: elfTexture.size().height/2)
        elf.physicsBody!.isDynamic = false
        elf.physicsBody?.affectedByGravity = true
        elf.run(makeElfFlap)
        elf.setScale(0.7)
        elf.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        elf.physicsBody!.categoryBitMask = ColliderType.Elf.rawValue
        elf.physicsBody!.collisionBitMask = ColliderType.Elf.rawValue
        self.addChild(elf)
        
        var playerHearts = 0
        let hearts = SKSpriteNode(imageNamed: "objectButterfly1")
        hearts.name = "butterfly"
        hearts.position = CGPoint(x: self.frame.midX - 450, y: self.frame.minY + 350)
        hearts.setScale(0.5)
        hearts.zPosition = 5
        addChild(hearts)
        scoreHearts = SKLabelNode(fontNamed: "Bradley Hand")
        scoreHearts.fontSize = 120
        scoreHearts.text = "\(playerHearts)"
        scoreHearts.position = CGPoint(x: self.frame.midX - 300, y: self.frame.minY + 350)
        addChild(scoreHearts)
        
        var score = 0
        let flower = SKSpriteNode(imageNamed: "objectFlower1")
        flower.name = "flower"
        flower.position = CGPoint(x: self.frame.midX - 450, y: self.frame.minY + 500)
        flower.setScale(0.4)
        flower.zPosition = 5
        addChild(flower)
        scoreLabel = SKLabelNode(fontNamed: "Bradley Hand")
        scoreLabel.fontSize = 120
        scoreLabel.text = "\(score)"
        scoreLabel.position = CGPoint(x: self.frame.midX - 300, y: self.frame.minY + 500)
        addChild(scoreLabel)
        
        timer1 = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.makeFlower), userInfo: nil, repeats: true)
        timer2 = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.makeEnemy), userInfo: nil, repeats: true)
        
        
        var indexElf = 0
        elfTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [self] timer3 in
            //var indexElf = Int.random(in: 1..<3)
            if indexElf == 0 {
                self.makeWaterelf()
                indexElf += 1
            }
            else if indexElf == 1 {
                self.makeButterflyelf()
                indexElf += 1
            }
            else { print("kein elf")
                indexElf = 0 }
        }
        
        
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
                if contact.bodyA.node?.name == "Enemy" {
                    if let sparkleStars = SKEmitterNode(fileNamed: "particle-stars"){
                                   sparkleStars.particleTexture = SKTexture(imageNamed: "particleHeart")
                                   sparkleStars.position = elf.position
                                   sparkleStars.zPosition = 10
                                   addChild(sparkleStars)}
                    contact.bodyA.node?.removeFromParent()
                    playerHearts += 1
                    if playerHearts == 20 {
                        won = true
                        gameover() }}
                }
            else if (contactMask == 3)
                {
                gameover()
                }
            else if (contactMask == 12)
                {
                contact.bodyA.node?.removeFromParent()
                contact.bodyB.node?.removeFromParent()
                score += 1
                //print("water + enemy")
                }
      
            else if (contactMask == 24)
            {
                score += 1
                //print("blume gegossen")
                if let sparkleStars = SKEmitterNode(fileNamed: "particle-stars"){
                               sparkleStars.particleTexture = SKTexture(imageNamed: "objectWaterdrop")
                               sparkleStars.position = Flower.position
                               sparkleStars.zPosition = 10
                               addChild(sparkleStars)}
                if score == 20 {
                    won = true
                    gameover() }
            }
            else if (contactMask == 33)
            {
                print("Elf getroffen")
                if let sparkleStars = SKEmitterNode(fileNamed: "particle-stars"){
                               sparkleStars.particleTexture = SKTexture(imageNamed: "particleHeart")
                               sparkleStars.position = Waterelf.position
                               sparkleStars.zPosition = 10
                               addChild(sparkleStars)}
                //movement Waterelf
            }
            else if (contactMask == 65)
            {
                print("Elf getroffen")
                if let sparkleStars = SKEmitterNode(fileNamed: "particle-stars"){
                               sparkleStars.particleTexture = SKTexture(imageNamed: "particleHeart")
                               sparkleStars.position = Waterelf.position
                               sparkleStars.zPosition = 10
                               addChild(sparkleStars)}
                //movement Butterflyelf
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
                elf.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 5000))
                if elf.position.y > frame.height/2 - 200 {
                    print("elf drüber")
                    elf.position.y = frame.height/2 - 200 }
                makeWater()
            }
            else
            {
                gameOver = false
                playerHearts = 0
                score = 0
                self.speed = 1
                self.removeAllChildren()
                removeAllChildren()
                setUpgame()
            }
    }
   
    override func update(_ currentTime: TimeInterval) {
        scoreHearts.text = "\(playerHearts)"
        scoreLabel.text = "\(score)"
    }
    
    func gameover(){
        if won == true {
            run("sound-heal")
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
        timer1.invalidate()
        elfTimer.invalidate()
        
        gameOverLabel.fontName = "Chalkduster"
        
        let GameOverBackground = SKSpriteNode(imageNamed: "backgroundNewGame")
        GameOverBackground.size = CGSize(width: 1290, height: 2796)
        GameOverBackground.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        GameOverBackground.zPosition = 10
        addChild(GameOverBackground)
    
        
        gameOverLabel.fontSize = 100
        gameOverLabel.text = "PLAY AGAIN"
        gameOverLabel.position = CGPoint(x : self.frame.midX + 200, y: self.frame.midY - 1000)
        gameOverLabel.zPosition = 4
        self.addChild(gameOverLabel)
    }
    
    @objc func makeFlower()
     {
         let flowerArray = ["objectFlower1", "objectFlower2", "objectFlower3", "objectFlower4"]
         let randomIndex = Int(arc4random_uniform(4))
         let FlowerTexture = SKTexture(imageNamed: flowerArray[randomIndex])
         
         let FlowerY = (-1) * Int.random(in: 100..<800)
         //let FlowerTexture = SKTexture(imageNamed: "objectFlower1.png")
         Flower = SKSpriteNode(texture: FlowerTexture)
         Flower.position = CGPoint(x: self.frame.width - 100, y: CGFloat(FlowerY))
         
         Flower.physicsBody = SKPhysicsBody(rectangleOf: FlowerTexture.size())
         Flower.physicsBody!.isDynamic = true
         Flower.physicsBody!.contactTestBitMask = ColliderType.Water.rawValue
         Flower.physicsBody!.categoryBitMask = ColliderType.Flower.rawValue
         Flower.physicsBody!.collisionBitMask = ColliderType.Flower.rawValue
         Flower.setScale(0.9)
         Flower.zPosition = 5
         addChild(Flower)
        
         let moveFlower = SKAction.move(to: CGPoint(x: -1000, y: Int(FlowerY)), duration: 6)
         Flower.run(moveFlower)
         
     }
    
    @objc func makeWater() {
        let waterTexture = SKTexture(imageNamed: "objectWaterdrop")
        water = SKSpriteNode(texture: waterTexture)
        water.position = CGPoint(x: elf.position.x + 200, y: elf.position.y - 100)
        let moveWaterForward = SKAction.move(by: CGVector(dx: 400, dy: 0), duration: 1)
        water.run(moveWaterForward)
        water.physicsBody = SKPhysicsBody(rectangleOf: waterTexture.size())
        water.physicsBody!.isDynamic = true
        water.physicsBody?.affectedByGravity = true
        water.physicsBody!.contactTestBitMask = ColliderType.Flower.rawValue
        water.physicsBody!.categoryBitMask = ColliderType.Water.rawValue
        water.physicsBody!.collisionBitMask = ColliderType.Water.rawValue
        water.setScale(0.2)
        self.addChild(water)
        
    }
    
   @objc func makeEnemy()
    {
        var EnemyActualY: CGFloat = 0.0
        let EnemyY = arc4random() % UInt32(self.frame.height/2)
        let EnemyTexture = SKTexture(imageNamed: "objectButterfly1.png")
        //Make flapping butterfly
        let objectButterfly2  = SKTexture(imageNamed: "objectButterfly2.png")
        let objectButterfly3 = SKTexture(imageNamed: "objectButterfly3.png")
        let objectButterfly0 = SKTexture(imageNamed: "objectButterfly0.png")
        let animation = SKAction.animate(with: [EnemyTexture, objectButterfly2, objectButterfly3, objectButterfly0], timePerFrame: 0.08)
        let moveButterfly = SKAction.move(to: CGPoint(x: -1000, y: 200), duration: 6)
        let makeButterflyFlap = SKAction.repeatForever(animation)
        
        Enemy = SKSpriteNode(texture: EnemyTexture)
        if EnemyY < UInt32(self.frame.height/4)
        { EnemyActualY = -2 * CGFloat(EnemyY) }
        else
        { EnemyActualY = CGFloat(EnemyY) }
        
        Enemy.position = CGPoint(x: self.frame.width, y: EnemyActualY)
        Enemy.run(moveButterfly)
        Enemy.run(makeButterflyFlap)
        Enemy.name = "Enemy"
        Enemy.physicsBody = SKPhysicsBody(rectangleOf: EnemyTexture.size())
        Enemy.physicsBody!.isDynamic = true
        Enemy.physicsBody!.contactTestBitMask = ColliderType.Elf.rawValue
        Enemy.physicsBody!.categoryBitMask = ColliderType.Enemy.rawValue
        Enemy.physicsBody!.collisionBitMask = ColliderType.Enemy.rawValue
        Enemy.setScale(0.8)
        self.addChild(Enemy)
    }
    
    @objc func makeWaterelf()
     {
         let elfArray = ["waterelf1", "waterelf2", "waterelf3"]
         let elfTexture1 = SKTexture(imageNamed: elfArray[0])
         let elfTexture2 = SKTexture(imageNamed: elfArray[1])
         let elfTexture3 = SKTexture(imageNamed: elfArray[2])
         let animation = SKAction.animate(with: [elfTexture1, elfTexture2, elfTexture3], timePerFrame: 0.08)
         let makeElfFlap = SKAction.repeatForever(animation)
         
         Waterelf = SKSpriteNode(texture: elfTexture1)
         let ElfY = Int.random(in: 0..<1000)
         Waterelf.position = CGPoint(x: self.frame.width - 100, y: CGFloat(ElfY))
         
         Waterelf.physicsBody = SKPhysicsBody(rectangleOf: elfTexture1.size())
         Waterelf.physicsBody!.isDynamic = true
         Waterelf.physicsBody!.contactTestBitMask = ColliderType.Elf.rawValue
         Waterelf.physicsBody!.categoryBitMask = ColliderType.Waterelf.rawValue
         Waterelf.physicsBody!.collisionBitMask = ColliderType.Waterelf.rawValue
         Waterelf.setScale(0.7)
         Waterelf.zPosition = 5
         self.addChild(Waterelf)
         Waterelf.run(makeElfFlap)
         let moveFlower = SKAction.move(to: CGPoint(x: -1000, y: Int(ElfY)), duration: 6)
         let seq = SKAction.sequence([moveFlower, .removeFromParent()])
         Waterelf.run(seq)
     }
    
    @objc func makeButterflyelf()
    {
        let elfArray = ["butterflyelf1", "butterflyelf2", "butterflyelf3"]
        let elfTexture1 = SKTexture(imageNamed: elfArray[0])
        let elfTexture2 = SKTexture(imageNamed: elfArray[1])
        let elfTexture3 = SKTexture(imageNamed: elfArray[2])
        let animation = SKAction.animate(with: [elfTexture1, elfTexture2, elfTexture3], timePerFrame: 0.08)
        let makeElfFlap = SKAction.repeatForever(animation)
        
        Butterflyelf = SKSpriteNode(texture: elfTexture1)
        let ElfY = Int.random(in: 0..<800)
        Butterflyelf.position = CGPoint(x: self.frame.width - 100, y: CGFloat(ElfY))
        
        Butterflyelf.physicsBody = SKPhysicsBody(rectangleOf: elfTexture1.size())
        Butterflyelf.physicsBody!.isDynamic = true
        Butterflyelf.physicsBody!.contactTestBitMask = ColliderType.Elf.rawValue
        Butterflyelf.physicsBody!.categoryBitMask = ColliderType.Butterflyelf.rawValue
        Butterflyelf.physicsBody!.collisionBitMask = ColliderType.Butterflyelf.rawValue
        Butterflyelf.setScale(0.7)
        Butterflyelf.zPosition = 5
        self.addChild(Butterflyelf)
        Butterflyelf.run(makeElfFlap)
        let moveFlower = SKAction.move(to: CGPoint(x: -1000, y: Int(ElfY)), duration: 6)
        let seq = SKAction.sequence([moveFlower, .removeFromParent()])
        Butterflyelf.run(seq)
    }
    
    func run(_ fileName: String){
            run(SKAction.repeat((SKAction.playSoundFileNamed(fileName, waitForCompletion: true)), count: 1))
        }
    
}
