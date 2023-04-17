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
    let soundHit = SKAction.playSoundFileNamed("sfx_hit.wav", waitForCompletion: false)
    let soundExplosion = SKAction.playSoundFileNamed("explosin.wav", waitForCompletion: false)
    var dragon  = SKSpriteNode()
    var bg = SKSpriteNode()
    var water = SKSpriteNode()
    var boomExplosion = SKSpriteNode()
    var Enemy = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var highestScoreLabel = SKLabelNode()
    var TapTap = SKLabelNode()
    var score = 0
    var timer1 = Timer()
    var timer2 = Timer()
    var highestScore: Int = 0
    var gameOver = false
    
     
    // Enum to handle collision. Bird vs Object = 1 + 2 =3 for example
     
    enum ColliderType: UInt32
    {
        case Bird = 1
        case Object = 2
        case Gap = 4
        case Enemy = 8
        case Water = 16
    }
    
   
    @objc func makeWater() {
        let waterTexture = SKTexture(imageNamed: "objectWaterdrop")
        water = SKSpriteNode(texture: waterTexture)
        water.position = CGPoint(x: -0.2 * self.frame.width + dragon.size.width, y: dragon.position.y)
        let moveWaterForward = SKAction.move(by: CGVector(dx: self.frame.width, dy: 0), duration: 3)
        water.run(moveWaterForward)
        water.physicsBody = SKPhysicsBody(rectangleOf: waterTexture.size())
        water.physicsBody!.isDynamic = true
        water.physicsBody?.affectedByGravity = false
        water.physicsBody!.contactTestBitMask = ColliderType.Enemy.rawValue
        water.physicsBody!.categoryBitMask = ColliderType.Water.rawValue
        water.physicsBody!.collisionBitMask = ColliderType.Water.rawValue
        self.addChild(water)
    }
    
   @objc func makeEnemy()
    {
        var EnemyActualY: CGFloat = 0.0
        let EnemyY = arc4random() % UInt32(self.frame.height/2)
        let EnemyTexture = SKTexture(imageNamed: "objectButterfly1.png")
        //Make Rotating Blade
        /*let bladeTexture2  = SKTexture(imageNamed: "blade_2.png")
        let bladeTexture3 = SKTexture(imageNamed: "blade_3.png")
        let Bladeanimation = SKAction.animate(with: [EnemyTexture, bladeTexture2, bladeTexture3], timePerFrame: 0.08)*/
        let moveBladeAttack = SKAction.move(to: CGPoint(x: dragon.position.x, y: dragon.position.y), duration: 2.3)
        //let makeBladeRotate = SKAction.repeatForever(Bladeanimation)
        
        Enemy = SKSpriteNode(texture: EnemyTexture)
        if EnemyY < UInt32(self.frame.height/4)
        { EnemyActualY = -2 * CGFloat(EnemyY) }
        else
        { EnemyActualY = CGFloat(EnemyY) }
        Enemy.position = CGPoint(x: self.frame.width, y: EnemyActualY)
        let moveEnemyBackward = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 150))
       // let moveEnemyAttack = SKAction.move(to: CGPoint(x: bird.position.x, y: bird.position.y), duration: 2.3)
       // Enemy.run(moveEnemyAttack)
        Enemy.run(moveEnemyBackward)
        Enemy.run(moveBladeAttack)
        //Enemy.run(makeBladeRotate)
        Enemy.physicsBody = SKPhysicsBody(rectangleOf: EnemyTexture.size())
        Enemy.physicsBody!.isDynamic = false
        Enemy.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        Enemy.physicsBody!.categoryBitMask = ColliderType.Enemy.rawValue
        Enemy.physicsBody!.collisionBitMask = ColliderType.Enemy.rawValue
        Enemy.setScale(0.5)
        self.addChild(Enemy)

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if (gameOver==false)
        {
            //let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue
            {   score += 1
                scoreLabel.text = String(score) }
    
        else if (contactMask == 24)
        {
            self.run(soundExplosion)
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.removeFromParent()
            //Handle Explosion
            let ExplosionTexture0 = SKTexture(imageNamed: "explosion0.png")
            let ExplosionTexture1 = SKTexture(imageNamed: "explosion1.png")
            let ExplosionTexture2 = SKTexture(imageNamed: "explosion2.png")
            let ExposionEnd = SKTexture(imageNamed: "output.png")
            let animation = SKAction.animate(with: [ExplosionTexture0, ExplosionTexture1,ExplosionTexture2, ExposionEnd], timePerFrame: 0.1)
            boomExplosion = SKSpriteNode(texture: ExplosionTexture2)
            boomExplosion.position = CGPoint(x: water.position.x, y: water.position.y)
            boomExplosion.run(animation)
            self.addChild(boomExplosion)
            
        }
      
        else
        {
        self.run(soundHit)
        self.speed = 0
        gameOver = true
        timer1.invalidate()
        timer2.invalidate()
        gameOverLabel.fontName = "Chalkduster"
        let GameOverBackground = SKSpriteNode(imageNamed: "gameOverBack.png")
            GameOverBackground.size = CGSize(width: 600, height: 300)
        GameOverBackground.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        GameOverBackground.zPosition = 1
        self.addChild(GameOverBackground)
        if (score>highestScore)
        {
            highestScore = score
        }
        highestScoreLabel.fontName = "Chalkduster"
        highestScoreLabel.fontSize = 30
        highestScoreLabel.position = CGPoint(x : self.frame.midX , y: self.frame.midY + 300)
        highestScoreLabel.text = "Best Score: " + String(highestScore)
        highestScoreLabel.zPosition = 2
        scoreLabel.fontSize = 30
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.position = CGPoint(x : self.frame.midX , y: self.frame.midY + 200)
        scoreLabel.zPosition = 2
        scoreLabel.text = "Score: " + String(score)
        gameOverLabel.fontSize = 30
        gameOverLabel.text = "PLAY AGAIN"
        gameOverLabel.position = CGPoint(x : self.frame.midX, y: self.frame.midY + 400)
        gameOverLabel.zPosition = 2
        self.addChild(gameOverLabel)
        self.addChild(highestScoreLabel)
        }
        }
    }
 
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.setUpgame()
    }
    
    func setUpgame()
    {
        TapTap.position =  CGPoint(x: self.frame.midX, y: self.frame.height/2-300)
        TapTap.fontName = "Chalkduster"
        TapTap.text = "Tap the screen to start!"
        TapTap.fontSize = 30
        self.addChild(TapTap)
        //Array Random number index to rotate background and dragon pics
        var ArrayName : [String] = []
        var randomIndexBackground: Int = 0
        let backgroundArray = ["background.png", "background1.png", "background2.png", "background4.png"]
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
        var randomIndexDragon: Int = 0
        randomIndexDragon = Int(arc4random_uniform(2))
        if randomIndexDragon == 0
        {
            ArrayName = ["D1FLY_000.png", "D1FLY_001.png", "D1FLY_004.png", "D1ATTACK_005.png"]
        }
        else
        {
            ArrayName = ["D2FLY_000.png", "D2FLY_001.png", "D2FLY_004.png", "D2ATTACK_005.png"]
            
        }
        let birdTexture = SKTexture(imageNamed: ArrayName[0])
        let birdTexture2 = SKTexture(imageNamed: ArrayName[1])
        let birdTexture3 = SKTexture(imageNamed: ArrayName[2])
        let birdTexture4 = SKTexture(imageNamed: ArrayName[3])
        let animation = SKAction.animate(with: [birdTexture, birdTexture2,birdTexture3, birdTexture4], timePerFrame: 0.08)
        let makeBirdFlap = SKAction.repeatForever(animation)
        dragon = SKSpriteNode(texture: birdTexture)
        dragon.position = CGPoint(x: -0.2 * self.frame.width, y: self.frame.midY)
        dragon.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        dragon.physicsBody!.isDynamic = false
        dragon.run(makeBirdFlap)
        dragon.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        dragon.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        dragon.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        self.addChild(dragon)
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontSize = 90
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height/2-130)
        self.addChild(scoreLabel)
        
        timer2 = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.makeEnemy), userInfo: nil, repeats: true)
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
        if (gameOver == false)
        {
        dragon.physicsBody!.isDynamic = true
        dragon.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        dragon.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
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
    }
}
