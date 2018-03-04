//
//  GameScene.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-02-26.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//  Icon made by Becris from www.flaticon.com
//  Icon made by Freepik from www.flaticon.com
//  Royalty Free Music from Bensound

//TODO:
// Make it so missileExplosion only damages things once..
// Make missileExmplosion look more natural- animated?
// Make an explosion when things die
// Make explosion sound
// add nice lanchscreen storyboard
// Make better name
// add different levels based on planets
// add unlockable weapons, upgrades, etc based on score?
// Earn credits?
// inapp purchases?
// Make aliens move "randomly"
// add pause button
// add different types of enemies
// Bosses


import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

// Collision bitmasks for all objects
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Player: UInt32 = 0x1 << 1
    static let Alien: UInt32 = 0x1 << 2
    static let Asteroid: UInt32 = 0x1 << 3
    static let Projectile: UInt32 = 0x1 << 4
    static let Explosion: UInt32 = 0x1 << 5
    static let AlienLaser: UInt32 = 0x1 << 6
    
    static let Edge: UInt32 = 0x1 << 7
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let kPlayerName = "player"
    let kAlienName = "alien"
    let kAlienLaserName = "alienlaser"
    let kAsteroidName = "asteroid"
    let kLaserName = "laser"
    let kMissileName = "missile"
    let kMissileExplosionName = "missileExplosion"
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    var scoreLabel = SKLabelNode(fontNamed: "Avenir")
    var healthLabel = SKLabelNode(fontNamed: "Avenir")
    
    // Starts with the screen not being pressed
    var touchingScreen = false
    
    // Shoots every x seconds
    var fireRate = 0.3
    
    // The players weapon choice
    var playerWeapon = ""
    
    // Time since last updated
    private var lastUpdateTime: CFTimeInterval = 0
    
    private var bgMusicPlayer: AVAudioPlayer!
    
    let motionManager = CMMotionManager()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setupScreen()
        setupMusic()
        setupPlayer()
        setupWeapon()
        setUpAliens()
        setUpAsteroids()
        setupHud()
        motionManager.startAccelerometerUpdates()
    }
    
    func setupScreen() {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        let edge = SKNode()
        edge.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        edge.physicsBody!.usesPreciseCollisionDetection = true
        edge.physicsBody!.categoryBitMask = PhysicsCategory.Edge
    }
    
    func setupMusic() {
        let path = Bundle.main.path(forResource: "bensound-deepblue", ofType: "mp3")!
        let url = URL(fileURLWithPath: path)
        do {
            bgMusicPlayer = try AVAudioPlayer(contentsOf: url)
            bgMusicPlayer.numberOfLoops = -1
            bgMusicPlayer.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
        bgMusicPlayer.play()
    }
    
    func setupPlayer() {
        let player = makePlayer()
        player.position = CGPoint(x: size.width * 0.5, y: size.height * 0.1)
        addChild(player)
    }
    
    func setupWeapon() {
        switch GameData.shared.weaponChosen {
        case "laser":
            fireRate = 0.3
            playerWeapon = kLaserName
        case "missile":
            fireRate = 1
            playerWeapon = kMissileName
        default:
            fireRate = 1
        }
    }
    
    func setUpAliens() {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addAlien),
                SKAction.wait(forDuration: Double(random(min: CGFloat(0.1), max: CGFloat(0.4))))
                ])
        ))
    }
    
    func setUpAsteroids() {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addAstroid),
                SKAction.wait(forDuration: Double(random(min: CGFloat(1), max: CGFloat(6))))
                ])
        ))
    }
    
    func setupHud() {
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 15
        scoreLabel.fontColor = SKColor.white
        scoreLabel.text = String("Score: \(GameData.shared.playerScore)")
        scoreLabel.position = CGPoint(
            x: scoreLabel.frame.size.width/2 + 15,
            y: size.height - scoreLabel.frame.size.height
        )
        addChild(scoreLabel)
        
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 15
        healthLabel.fontColor = SKColor.green
        healthLabel.text = String("Health: \(GameData.shared.playerHealth)%")
        healthLabel.position = CGPoint(
            x: healthLabel.frame.size.width/2,
            y: size.height - (20 + healthLabel.frame.size.height/2)
        )
        addChild(healthLabel)
    }
    
    func updateHud(){
        healthLabel.text = String("Health: \(GameData.shared.playerHealth)%")
        scoreLabel.text = String("Score: \(GameData.shared.playerScore)")
    }
    
    func makePlayer() -> SKNode {
        let player = SKSpriteNode(imageNamed: "spaceship")
        player.size = CGSize(width: 35, height: 35)
        player.name = kPlayerName
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody!.isDynamic = true
        player.physicsBody!.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Alien | PhysicsCategory.Asteroid | PhysicsCategory.AlienLaser
        player.physicsBody?.collisionBitMask = PhysicsCategory.Edge
        
        return player
    }

    
    func addAlien() {
        let alien = SKSpriteNode(imageNamed: "alien")
        alien.name = kAlienName
        alien.size = CGSize(width: 40, height: 40)
        alien.userData = NSMutableDictionary()
        setAlienHealth(alien: alien)
        
        alien.physicsBody = SKPhysicsBody(texture: alien.texture!, size: alien.size)
        alien.physicsBody?.isDynamic = false
        alien.physicsBody?.categoryBitMask = PhysicsCategory.Alien
        alien.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Projectile | PhysicsCategory.Explosion
        alien.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualX = random(min: alien.size.width/2, max: size.width - alien.size.width/2)
        alien.position = CGPoint(x: actualX, y: size.height + alien.size.height/2)
        addChild(alien)
        
        let actualDuration = random(min: CGFloat(7.0), max: CGFloat(10.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -alien.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        alien.run(SKAction.sequence([actionMove, actionMoveDone]))
        setUpAlienLaser(alien: alien)
    }
    
    func addAstroid() {
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.name = kAsteroidName
        asteroid.size = CGSize(width: 80, height: 80)
        asteroid.userData = NSMutableDictionary()
        setAstroidHealth(astroid: asteroid)
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.isDynamic = false
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.Asteroid
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Projectile | PhysicsCategory.Explosion
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualX = random(min: asteroid.size.width/2, max: size.width - asteroid.size.width/2)
        asteroid.position = CGPoint(x: actualX, y: size.height + asteroid.size.height/2)
        addChild(asteroid)
        
        let actualDuration = random(min: CGFloat(12.0), max: CGFloat(15.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: random(min: asteroid.size.width/2, max: size.width - asteroid.size.width/2), y: -asteroid.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addAlienLaser(alien: SKSpriteNode) {
        let alienLaser = SKSpriteNode(color: SKColor.green, size: CGSize(width: 2, height: 16))
        alienLaser.name = kAlienLaserName
        
        alienLaser.physicsBody = SKPhysicsBody(rectangleOf: alienLaser.size)
        alienLaser.physicsBody?.isDynamic = false
        alienLaser.physicsBody?.categoryBitMask = PhysicsCategory.AlienLaser
        alienLaser.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        alienLaser.physicsBody?.collisionBitMask = PhysicsCategory.None
        alienLaser.physicsBody?.usesPreciseCollisionDetection = true
        
        let actualDuration = random(min: CGFloat(4.0), max: CGFloat(5.0))
        alienLaser.position = alien.position - CGPoint(x: 0, y: alien.size.height/2 + alienLaser.size.height/2)
        let actionMove = SKAction.move(to: CGPoint(x: alienLaser.position.x, y: alienLaser.position.y - 1000), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        alienLaser.run(SKAction.sequence([actionMove, actionMoveDone]))
        addChild(alienLaser)
    }
    
    func setUpAlienLaser(alien: SKSpriteNode) {
        let wait = SKAction.wait(forDuration: Double(random(min: CGFloat(1), max: CGFloat(4))))
        let run = SKAction.run {
            self.addAlienLaser(alien: alien)
        }
        alien.run(SKAction.repeatForever(SKAction.sequence([wait, run])))
    }
    
    func firePlayerWeapon(){
        if(playerWeapon == kLaserName){
            firePlayerLaser()
        }
        if(playerWeapon == kMissileName){
            firePlayerMissile()
        }
    }
    
    func firePlayerLaser() {
        run(SKAction.playSoundFileNamed("laser.mp3", waitForCompletion: false))
        let laser = SKSpriteNode(color: SKColor.red, size: CGSize(width: 2, height: 16))
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            laser.position = player.position + CGPoint(x: 0, y: player.size.height/2 + laser.size.height/2)
        }
        laser.name = kLaserName
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        laser.physicsBody?.isDynamic = true
        laser.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        laser.physicsBody?.contactTestBitMask = PhysicsCategory.Alien | PhysicsCategory.Asteroid
        laser.physicsBody?.collisionBitMask = PhysicsCategory.None
        laser.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(laser)
        let actionMove = SKAction.move(to: laser.position + CGPoint(x: 0, y: 3000), duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        laser.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func firePlayerMissile() {
        run(SKAction.playSoundFileNamed("missile.wav", waitForCompletion: false))
        let missile = SKSpriteNode(imageNamed: "missile")
        missile.size = CGSize(width: 19, height: 40)
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            missile.position = player.position + CGPoint(x: 0, y: player.size.height/2 + missile.size.height/2)
        }
        missile.name = kMissileName
        missile.physicsBody = SKPhysicsBody(rectangleOf: missile.size)
        missile.physicsBody?.isDynamic = true
        missile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        missile.physicsBody?.contactTestBitMask = PhysicsCategory.Alien | PhysicsCategory.Asteroid
        missile.physicsBody?.collisionBitMask = PhysicsCategory.None
        missile.physicsBody?.usesPreciseCollisionDetection = true
        missile.physicsBody?.allowsRotation = false
        
        addChild(missile)
        let actionMove = SKAction.move(to: missile.position + CGPoint(x: 0, y: 3000), duration: 7.5)
        let actionMoveDone = SKAction.removeFromParent()
        missile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func missileExplosion(missile: SKNode) {
        run(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false))
        let missileExplosion = SKSpriteNode(imageNamed: "explosion")
        missileExplosion.size = CGSize(width: 35, height: 35)
        missileExplosion.position = missile.position
        
        missileExplosion.name = kMissileExplosionName
        missileExplosion.physicsBody = SKPhysicsBody(rectangleOf: missileExplosion.size)
        missileExplosion.physicsBody?.isDynamic = true
        missileExplosion.physicsBody?.categoryBitMask = PhysicsCategory.Explosion
        missileExplosion.physicsBody?.contactTestBitMask = PhysicsCategory.Alien | PhysicsCategory.Asteroid
        missileExplosion.physicsBody?.collisionBitMask = PhysicsCategory.None
        missileExplosion.physicsBody?.allowsRotation = false
        
        addChild(missileExplosion)
        let actionMove = SKAction.move(to: missileExplosion.position, duration: 0.3)
        let actionMoveDone = SKAction.removeFromParent()
        missileExplosion.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func processUserMotion(forUpdate currentTime: CFTimeInterval) {
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            if let data = motionManager.accelerometerData {
                if data.acceleration.x > 0.001 {
                    //print("Acceleration: \(data.acceleration.x)")
                    //player.physicsBody!.applyForce(CGVector(dx: 30 * CGFloat(data.acceleration.x), dy: 0))
                    player.physicsBody?.velocity.dx = CGFloat(100 * ((data.acceleration.x * 10) * (data.acceleration.x * 1.25)))
                }
                if data.acceleration.x < -0.001 {
                    //print("Acceleration: \(data.acceleration.x)")
                    //player.physicsBody!.applyForce(CGVector(dx: 30 * CGFloat(data.acceleration.x), dy: 0))
                    player.physicsBody?.velocity.dx = CGFloat(100 * ((data.acceleration.x * 10) * (data.acceleration.x * -1.25)))
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        processUserMotion(forUpdate: currentTime)
        GameData.shared.playerScore = GameData.shared.playerScore + 1
        updateHud()
        let timeSinceLastUpdate = currentTime - lastUpdateTime
        if timeSinceLastUpdate > fireRate && touchingScreen {
            firePlayerWeapon()
            lastUpdateTime = currentTime
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingScreen = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingScreen = false
    }
    
    func collisionBetween(ob1: SKNode, ob2: SKNode){
        if ob1.name == kPlayerName && ob2.name == kAlienName {
            ob2.removeFromParent()
            playerTakesDamage(damage: 40, view: view!)
        }
        
        if ob1.name == kPlayerName && ob2.name == kAsteroidName {
            ob2.removeFromParent()
            playerTakesDamage(damage: 90, view: view!)
        }
        
        if ob1.name == kPlayerName && ob2.name == kAlienLaserName {
            ob2.removeFromParent()
            playerTakesDamage(damage: 25, view: view!)
        }
        
        if ob1.name == kAlienName && ob2.name == kLaserName {
            subtractHealth(sprite: ob1, damage: 1)
            ob2.removeFromParent()
        }
        
        if ob1.name == kAsteroidName && ob2.name == kLaserName {
            subtractHealth(sprite: ob1, damage: 1)
            ob2.removeFromParent()
        }
        
        if ob1.name == kAlienName && ob2.name == kMissileName {
            subtractHealth(sprite: ob1, damage: 1)
            ob2.removeFromParent()
            missileExplosion(missile: ob2)
        }
        
        if ob1.name == kAsteroidName && ob2.name == kMissileName {
            subtractHealth(sprite: ob1, damage: 1)
            ob2.removeFromParent()
            missileExplosion(missile: ob2)
        }
        
        if ob1.name == kAlienName && ob2.name == kMissileExplosionName {
            subtractHealth(sprite: ob1, damage: 4)
        }
        
        if ob1.name == kAsteroidName && ob2.name == kMissileExplosionName {
            subtractHealth(sprite: ob1, damage: 4)
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == kPlayerName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kPlayerName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kAlienName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kAlienName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kAsteroidName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kAsteroidName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
    }
    
}
