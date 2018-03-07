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
// Change eyeboss image..
// Add stats like "Damage" "Fire Rate" etc under each weapon
// Make explosion sound
// Make better name
// add unlockable weapons, upgrades, etc based on score?
// Earn credits?
// inapp purchases? - Upgrades drop more, more max health, Revive
// Make aliens move "randomly"
// add pause button
// add different types of enemies
// Bosses reverse controls- confusion
// Make aliens fire aoe, crossing diagonal bullets
// Make asteroid break into two smaller asteroids
// Make laser sound better
// Upgrades: More bullets parallel, diagonal bullets, energy shield, DOT fire, freeze weapon?
// Swipe up, move forward fixed amount, so two different y axis positions
// Swipe to move like snake vs block
// Improve HUD- show upgrades
// Increase spawn rates with time
// change enemies after a boss is defeated

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

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
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
    static let None: UInt32 = 0
    static let All: UInt32 = UInt32.max
    static let Player: UInt32 = 0x1 << 1
    static let Alien: UInt32 = 0x1 << 2
    static let Asteroid: UInt32 = 0x1 << 3
    static let PlayerProjectile: UInt32 = 0x1 << 4
    static let MissileExplosion: UInt32 = 0x1 << 5
    static let AlienLaser: UInt32 = 0x1 << 6
    static let UpgradePack: UInt32 = 0x1 << 7
    static let EyeBoss: UInt32 = 0x1 << 8
    static let EyeBossLaserAttack: UInt32 = 0x1 << 9
    
    static let Edge: UInt32 = 0x1 << 11
}

struct BaseFireRate {
    static let Laser = 0.2
    static let Missile = 1.0
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var playerAlive = false
    let kPlayerName = "player"
    let kAlienName = "alien"
    let kAlienLaserName = "alienlaser"
    let kAsteroidName = "asteroid"
    let kLaserName = "laser"
    let kUpgradedLaserName = "upgradedLaser"
    let kMissileName = "missile"
    let kMissileExplosionName = "missileExplosion"
    let kHealthPackName = "healthPack"
    let kFireRateUpgradeName = "firerateUpgrade"
    let kThreeShotUpgradeName = "threeShotUpgrade"
    let kEyeBossName = "eyeBoss"
    let kEyeBossLaserName = "eyeBossLaser"
    let kEyeBossLaserChargeName = "eyeBossLaserCharge"
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
    
    // The number of fireRate upgrades
    var fireRateUpgradeNumber = 0
    
    // All the possible upgrades
    private var threeShotUpgrade = false
    private var fiveShotUpgrade = false
    
    // Time since last fired
    private var lastFiredTime: CFTimeInterval = 0
    
    // Time since gameScene started
    private var sinceStart: CFTimeInterval = 0
    
    // Is called in update only the first time
    private var setStartBool = true
    private var startTime: CFTimeInterval = 0
    
    
    // How long a player must play before each boss spawns
    private var timeToSpawnEyeBoss = 1.0
    
    // Each boss starts unspawned
    private var eyeBossSpawned = false
    private var eyeBossFullySpawned = false
    
    // Attack rate of each boss- seconds between each attack
    private var eyeBossAttackRate = 5.0
    
    // Time each boss attacked last
    private var timeEyeBossAttack: CFTimeInterval = 0
    
    // Score for killing each enemy
    let alienKillScore = 30
    let asteroidKillScore = 90
    let eyeBossKillScore = 5000
    
    var damagedByPlayerLaserArray: [String] = []
    var damagedByPlayerMissileArray: [String] = []
    var damagedByPlayerMissileExplosionArray: [String] = []
    
    private var bgMusicPlayer: AVAudioPlayer!
    
    let motionManager = CMMotionManager()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        setUpDamageArrays()
        setupScreen()
        setupMusic()
        setupPlayer()
        setupWeapon()
        setUpAliens()
        setUpAsteroids()
        setupHud()
        motionManager.startAccelerometerUpdates()
    }
    
    func setUpDamageArrays(){
        damagedByPlayerLaserArray = [kAlienName, kAsteroidName, kEyeBossName]
        damagedByPlayerMissileArray = [kAlienName, kAsteroidName, kEyeBossName]
        damagedByPlayerMissileExplosionArray = [kAlienName, kAsteroidName, kEyeBossName]
    }
    
    func setupScreen() {
        scene?.scaleMode = .aspectFit
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
        playerAlive = true
    }
    
    func setupWeapon() {
        switch GameData.shared.weaponChosen {
        case "laser":
            fireRate = BaseFireRate.Laser * pow(0.8, Double(fireRateUpgradeNumber))
            playerWeapon = kLaserName
        case "missile":
            fireRate = BaseFireRate.Missile * pow(0.8, Double(fireRateUpgradeNumber))
            playerWeapon = kMissileName
        default:
            fireRate = 1
        }
        print("Fire rate is \(fireRate)")
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
        player.zPosition = 5
        player.name = kPlayerName
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size - CGSize(width: 5, height: 5))
        player.physicsBody!.isDynamic = true
        player.physicsBody!.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Alien | PhysicsCategory.Asteroid | PhysicsCategory.AlienLaser | PhysicsCategory.EyeBoss | PhysicsCategory.EyeBossLaserAttack
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
        alien.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion
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
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion
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
        let wait = SKAction.wait(forDuration: Double(random(min: CGFloat(1), max: CGFloat(8))))
        let run = SKAction.run {
            self.addAlienLaser(alien: alien)
        }
        alien.run(SKAction.repeatForever(SKAction.sequence([wait, run])))
    }
    
    func addHealthPowerup(position: CGPoint) {
        let healthPack = SKSpriteNode(imageNamed: "healthpack")
        healthPack.name = kHealthPackName
        healthPack.size = CGSize(width: 20, height: 20)
        healthPack.physicsBody = SKPhysicsBody(rectangleOf: healthPack.size)
        healthPack.physicsBody?.isDynamic = false
        healthPack.physicsBody?.categoryBitMask = PhysicsCategory.UpgradePack
        healthPack.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        healthPack.physicsBody?.collisionBitMask = PhysicsCategory.None
        healthPack.physicsBody?.usesPreciseCollisionDetection = true
        
        
        let actualDuration = random(min: CGFloat(20.0), max: CGFloat(24.0))
        healthPack.position = position
        let actionMove = SKAction.move(to: CGPoint(x: healthPack.position.x, y: position.y - 2000), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        healthPack.run(SKAction.sequence([actionMove, actionMoveDone]))
        addChild(healthPack)
    }
    
    func addFireRatePowerup(position: CGPoint) {
        let fireRatePack = SKSpriteNode(imageNamed: "firerateupgrade")
        fireRatePack.name = kFireRateUpgradeName
        fireRatePack.size = CGSize(width: 20, height: 20)
        fireRatePack.physicsBody = SKPhysicsBody(rectangleOf: fireRatePack.size)
        fireRatePack.physicsBody?.isDynamic = false
        fireRatePack.physicsBody?.categoryBitMask = PhysicsCategory.UpgradePack
        fireRatePack.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        fireRatePack.physicsBody?.collisionBitMask = PhysicsCategory.None
        fireRatePack.physicsBody?.usesPreciseCollisionDetection = true
        
        
        let actualDuration = random(min: CGFloat(20.0), max: CGFloat(24.0))
        fireRatePack.position = position
        let actionMove = SKAction.move(to: CGPoint(x: fireRatePack.position.x, y: position.y - 2000), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        fireRatePack.run(SKAction.sequence([actionMove, actionMoveDone]))
        addChild(fireRatePack)
    }
    
    func addThreeShotUpgradePowerUp(position: CGPoint) {
        let threeShotUpgrade = SKSpriteNode(imageNamed: "threeshotupgrade")
        threeShotUpgrade.name = kThreeShotUpgradeName
        threeShotUpgrade.size = CGSize(width: 20, height: 20)
        threeShotUpgrade.physicsBody = SKPhysicsBody(rectangleOf: threeShotUpgrade.size)
        threeShotUpgrade.physicsBody?.isDynamic = false
        threeShotUpgrade.physicsBody?.categoryBitMask = PhysicsCategory.UpgradePack
        threeShotUpgrade.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        threeShotUpgrade.physicsBody?.collisionBitMask = PhysicsCategory.None
        threeShotUpgrade.physicsBody?.usesPreciseCollisionDetection = true
        
        
        let actualDuration = random(min: CGFloat(20.0), max: CGFloat(24.0))
        threeShotUpgrade.position = position
        let actionMove = SKAction.move(to: CGPoint(x: threeShotUpgrade.position.x, y: position.y - 2000), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        threeShotUpgrade.run(SKAction.sequence([actionMove, actionMoveDone]))
        addChild(threeShotUpgrade)
    }
    
    
    // Spawns a random powerup, each with a percentChance divided by the total number of powerups available
    func spawnRandomPowerUp(position: CGPoint, percentChance: CGFloat) {
        spawnHealthRandom(position: position, percentChance: percentChance/3)
        spawnFireRateRandom(position: position, percentChance: percentChance/3)
        spawnThreeShotRandom(position: position, percentChance: percentChance/3)
    }
    
    // chance to spawn a healthPowerUp
    func spawnHealthRandom(position: CGPoint, percentChance: CGFloat) {
        let randomNum = random(min: CGFloat(0.0), max: CGFloat(100.0))
        if(randomNum <= percentChance){
            addHealthPowerup(position: position)
        }
    }
    
    // chance to spawn a fireRatePowerUp
    func spawnFireRateRandom(position: CGPoint, percentChance: CGFloat) {
        let randomNum = random(min: CGFloat(0.0), max: CGFloat(100.0))
        if(randomNum <= percentChance){
            addFireRatePowerup(position: position)
        }
    }
    
    // chance to spawn a threeShotPowerUp
    func spawnThreeShotRandom(position: CGPoint, percentChance: CGFloat) {
        let randomNum = random(min: CGFloat(0.0), max: CGFloat(100.0))
        if(randomNum <= percentChance){
            addThreeShotUpgradePowerUp(position: position)
        }
    }
    
    
    func firePlayerWeapon(){
        if(playerWeapon == kLaserName){
            firePlayerLaser(offset: 0.0)
            let audioNode = SKAudioNode(fileNamed: "laser")
            audioNode.autoplayLooped = false
            self.addChild(audioNode)
            let playAction = SKAction.play()
            audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 1), SKAction.removeFromParent()]))
        }
        if(playerWeapon == kLaserName) && threeShotUpgrade {
            firePlayerLaser(offset: -8.0)
            firePlayerLaser(offset: 8.0)
        }
        if(playerWeapon == kLaserName) && fiveShotUpgrade {
            firePlayerLaser(offset: -16.0)
            firePlayerLaser(offset: 16.0)
        }
        if(playerWeapon == kMissileName){
            firePlayerMissile()
        }
    }
    
    
    
    func firePlayerLaser(offset: CGFloat) {
        
        let laser = SKSpriteNode(color: SKColor.red, size: CGSize(width: 2, height: 16))
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            laser.position = player.position + CGPoint(x: offset, y: player.size.height/2 + laser.size.height/2)
        }
        laser.name = kLaserName
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        laser.physicsBody?.isDynamic = true
        laser.physicsBody?.categoryBitMask = PhysicsCategory.PlayerProjectile
        laser.physicsBody?.contactTestBitMask = PhysicsCategory.Alien | PhysicsCategory.Asteroid
        laser.physicsBody?.collisionBitMask = PhysicsCategory.None
        laser.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(laser)
        let actionMove = SKAction.move(to: laser.position + CGPoint(x: 0, y: 3000), duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        laser.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    
    
    func firePlayerMissile() {
        let audioNode = SKAudioNode(fileNamed: "missile")
        audioNode.autoplayLooped = false
        self.addChild(audioNode)
        let playAction = SKAction.play()
        audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 3), SKAction.removeFromParent()]))
        
        let missile = SKSpriteNode(imageNamed: "missile")
        missile.size = CGSize(width: 19, height: 40)
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            missile.position = player.position + CGPoint(x: 0, y: player.size.height/2 + missile.size.height/2)
        }
        missile.name = kMissileName
        missile.physicsBody = SKPhysicsBody(rectangleOf: missile.size)
        missile.physicsBody?.isDynamic = true
        missile.physicsBody?.categoryBitMask = PhysicsCategory.PlayerProjectile
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
        let audioNode = SKAudioNode(fileNamed: "explosion")
        audioNode.autoplayLooped = false
        self.addChild(audioNode)
        let playAction = SKAction.play()
        audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
        let missileExplosion = SKSpriteNode()
        missileExplosion.alpha = 0.0
        missileExplosion.size = CGSize(width: 50, height: 50)
        missileExplosion.position = missile.position
        missileExplosion.userData = NSMutableDictionary()

        missileExplosion.name = kMissileExplosionName
        missileExplosion.physicsBody = SKPhysicsBody(rectangleOf: missileExplosion.size)
        missileExplosion.physicsBody?.isDynamic = true
        missileExplosion.physicsBody?.categoryBitMask = PhysicsCategory.MissileExplosion
        missileExplosion.physicsBody?.contactTestBitMask = PhysicsCategory.Alien | PhysicsCategory.Asteroid | PhysicsCategory.EyeBoss
        missileExplosion.physicsBody?.collisionBitMask = PhysicsCategory.None
        missile.physicsBody?.usesPreciseCollisionDetection = true
        missileExplosion.physicsBody?.allowsRotation = false

        addChild(missileExplosion)
        missileExplosion.run(SKAction.wait(forDuration: 0.0005), completion: { missileExplosion.removeFromParent() })
    }
    

    
    
    func missileExplosionEffect(position: CGPoint) {
        let missileExplosionEffect = SKEmitterNode(fileNamed: "MissileExplosionParticle.sks")
        missileExplosionEffect?.particlePosition = position
        missileExplosionEffect?.zPosition = 2
        addChild(missileExplosionEffect!)
        missileExplosionEffect?.run(SKAction.wait(forDuration: 2), completion: { missileExplosionEffect?.removeFromParent() })
    }
    
    func asteroidExplosionEffect(position: CGPoint) {
        let asteroidExplosion = SKEmitterNode(fileNamed: "AsteroidExplosionParticle.sks")
        asteroidExplosion?.particlePosition = position
        addChild(asteroidExplosion!)
        asteroidExplosion?.run(SKAction.wait(forDuration: 1), completion: { asteroidExplosion?.removeFromParent() })
        
        let asteroidScoreEffect = SKLabelNode(fontNamed: "Avenir")
        asteroidScoreEffect.fontSize = 20
        asteroidScoreEffect.fontColor = SKColor.white
        asteroidScoreEffect.text = "+\(asteroidKillScore)"
        asteroidScoreEffect.position = position
        asteroidScoreEffect.zPosition = 5
        addChild(asteroidScoreEffect)
        asteroidScoreEffect.run(SKAction.wait(forDuration: 1), completion: { asteroidScoreEffect.removeFromParent() })
    }
    
    func alienExplosionEffect(position: CGPoint) {
        let alienExplosion = SKEmitterNode(fileNamed: "AlienExplosionParticle.sks")
        alienExplosion?.particlePosition = position
        addChild(alienExplosion!)
        alienExplosion?.run(SKAction.wait(forDuration: 1), completion: { alienExplosion?.removeFromParent() })
        
        let alienScoreEffect = SKLabelNode(fontNamed: "Avenir")
        alienScoreEffect.fontSize = 20
        alienScoreEffect.fontColor = SKColor.white
        alienScoreEffect.text = "+\(alienKillScore)"
        alienScoreEffect.position = position
        alienScoreEffect.zPosition = 5
        addChild(alienScoreEffect)
        alienScoreEffect.run(SKAction.wait(forDuration: 1), completion: { alienScoreEffect.removeFromParent() })
    }
    
    // Sets up the first boss- eyeBoss
    func setUpEyeBoss() {
        stopSpawns()
        warningFlashing(scene: self.scene!)
        spawnEyeBoss()
        eyeBossSpawned = true
    }
    
    func stopSpawns() {
        removeAllActions()
    }
    
    // Spawns the first boss- eyeBoss
    // TODO: Play boss music
    func spawnEyeBoss() {
        let eyeBoss = SKSpriteNode(imageNamed: "eyeBoss1")
        eyeBoss.userData = NSMutableDictionary()
        setEyeBossHealth(eyeBoss: eyeBoss)
        eyeBoss.size = CGSize(width: 110, height: 152)
        eyeBoss.position = CGPoint(x: size.width/2, y: size.height + eyeBoss.size.height)
        eyeBoss.name = kEyeBossName
        eyeBoss.zPosition = 3
        
        addChild(eyeBoss)
        eyeBoss.run(SKAction.move(to: CGPoint(x: size.width/2, y: size.height - eyeBoss.size.height), duration: 10.0), completion: { () -> Void in
            self.setUpEyeBossPhysicsBody(eyeBoss: eyeBoss)
            self.eyeBossFullySpawned = true
        })
    }
    
    // Sets up the physicsBody of eyeBoss, called after it has moved into position
    func setUpEyeBossPhysicsBody(eyeBoss: SKSpriteNode){
        eyeBoss.physicsBody = SKPhysicsBody(texture: eyeBoss.texture!, size: eyeBoss.size)
        eyeBoss.physicsBody?.isDynamic = true
        eyeBoss.physicsBody?.affectedByGravity = false
        eyeBoss.physicsBody?.categoryBitMask = PhysicsCategory.EyeBoss
        eyeBoss.physicsBody?.contactTestBitMask = PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Player
        eyeBoss.physicsBody?.collisionBitMask = PhysicsCategory.None
        eyeBoss.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func processEyeBossMovement(forUpdate currentTime: CFTimeInterval) {
        if let eyeBoss = childNode(withName: kEyeBossName) as? SKSpriteNode {
            if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
                if player.position.x + 10 >= eyeBoss.position.x {
                    eyeBoss.physicsBody?.velocity.dx = CGFloat(60)
                } else if player.position.x - 10 < eyeBoss.position.x {
                    eyeBoss.physicsBody?.velocity.dx = CGFloat(-60)
                }
                if let eyeBossLaser = childNode(withName: kEyeBossLaserName) as? SKSpriteNode {
                    eyeBossLaser.position.x = eyeBoss.position.x
                }
                if let eyeBossLaserCharge = childNode(withName: kEyeBossLaserChargeName) as? SKSpriteNode {
                    eyeBossLaserCharge.position.x = eyeBoss.position.x
                }
            }
        }

    }
    
    // TODO: Add more eyeBoss attacks- 5 total?
    func processEyeBossAttacks(attackChosen: Int) {
        switch attackChosen {
        case 1:
            eyeBossLaserBeamAttack()
        case 2:
            eyeBossChargeAttack()
        default:
            return
        }
    }
    
    func eyeBossLaserBeamAttack() {
        //TODO: Change physics body of laser
        let audioNode = SKAudioNode(fileNamed: "laserchargesound")
        audioNode.autoplayLooped = false
        self.addChild(audioNode)
        let playAction = SKAction.play()
        audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
        
        let chargeLaser = SKSpriteNode(imageNamed: "lasercharge")
        chargeLaser.zPosition = 2
        chargeLaser.name = kEyeBossLaserChargeName
        chargeLaser.size = CGSize(width: 0, height: 0)
        if let eyeBoss = childNode(withName: kEyeBossName) as? SKSpriteNode {
            chargeLaser.position = eyeBoss.position - CGPoint(x: 0, y: eyeBoss.size.height/2)
        }
        addChild(chargeLaser)
        chargeLaser.run(SKAction.resize(toWidth: 172.8, height: 90, duration: 1.4), completion: {
            let audioNode2 = SKAudioNode(fileNamed: "laserbeamsound")
            audioNode2.autoplayLooped = false
            self.addChild(audioNode2)
            let playAction = SKAction.play()
            audioNode2.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 5), SKAction.removeFromParent()]))
            
            let eyeBossLaser = SKSpriteNode(imageNamed: "laserbeam")
            eyeBossLaser.size = CGSize(width: 172.8, height: 920.23)
            eyeBossLaser.zPosition = 2
            eyeBossLaser.name = self.kEyeBossLaserName
            
            eyeBossLaser.physicsBody = SKPhysicsBody(rectangleOf: eyeBossLaser.size)
            eyeBossLaser.physicsBody?.isDynamic = false
            eyeBossLaser.physicsBody?.categoryBitMask = PhysicsCategory.EyeBossLaserAttack
            eyeBossLaser.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile
            eyeBossLaser.physicsBody?.collisionBitMask = PhysicsCategory.None
            if let eyeBoss = self.childNode(withName: self.kEyeBossName) as? SKSpriteNode {
                eyeBossLaser.position = eyeBoss.position - CGPoint(x: 0, y: eyeBoss.size.height/2 + (eyeBossLaser.size.height/2 - chargeLaser.size.height/2))
            }
            chargeLaser.removeFromParent()
            self.addChild(eyeBossLaser)
            eyeBossLaser.run(SKAction.wait(forDuration: 3), completion: {
                eyeBossLaser.removeFromParent()
                //chargeLaser.removeFromParent()
            })
        })
    }
    
    func eyeBossChargeAttack() {
        if let eyeBoss = childNode(withName: kEyeBossName) as? SKSpriteNode {
            eyeBoss.texture = SKTexture(imageNamed: "eyeBoss2")
            let actionMove = SKAction.move(to: eyeBoss.position - CGPoint(x: 0, y: size.height + eyeBoss.size.height), duration: 2.0)
            
            eyeBoss.run(actionMove, completion: {
                eyeBoss.position = CGPoint(x: eyeBoss.position.x, y: self.size.height + eyeBoss.size.height)
                eyeBoss.texture = SKTexture(imageNamed: "eyeBoss1")
                eyeBoss.run(SKAction.move(to: CGPoint(x: eyeBoss.position.x, y: self.size.height - eyeBoss.size.height), duration: 1.5))
            })
        }
    }
    
    func playerTakesDamage(damage: Int, view: UIView) {
        GameData.shared.playerHealth = GameData.shared.playerHealth - damage
        // If the player has 0 or less health, go to GameOverScene
        if (GameData.shared.playerHealth <= 0) {
            if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
                player.removeFromParent()
                playerAlive = false
                missileExplosionEffect(position: player.position)
                let audioNode = SKAudioNode(fileNamed: "explosion")
                audioNode.autoplayLooped = false
                self.addChild(audioNode)
                let playAction = SKAction.play()
                audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
            }
            let wait = SKAction.wait(forDuration:2.5)
            let action = SKAction.run {
                gameOver(view: view)
            }
            run(SKAction.sequence([wait,action]))
            
        }
    }
    
    func subtractHealth(sprite: SKNode, damage: Int) {
        let currentHealth: Int = sprite.userData?.value(forKey: "health") as! Int
        let newHealth = currentHealth - damage
        sprite.userData?.setValue(newHealth, forKey: "health")
        if (newHealth <= 0) {
            if(sprite.name == kAlienName){
                alienExplosionEffect(position: sprite.position)
                GameData.shared.playerScore = GameData.shared.playerScore + alienKillScore
                spawnRandomPowerUp(position: sprite.position, percentChance: 1.0)
            }
            if(sprite.name == kAsteroidName){
                asteroidExplosionEffect(position: sprite.position)
                GameData.shared.playerScore = GameData.shared.playerScore + asteroidKillScore
                spawnRandomPowerUp(position: sprite.position, percentChance: 2.0)
            }
            if(sprite.name == kEyeBossName){
                //TODO: Make eyeBoss explosion and sound- like an eyeball poping
                GameData.shared.playerScore = GameData.shared.playerScore + eyeBossKillScore
                eyeBossFullySpawned = false
                spawnRandomPowerUp(position: sprite.position, percentChance: 100.0)
                let wait = SKAction.wait(forDuration:2.5)
                let action = SKAction.run {
                    // Increase spawn and change spawns
                    self.setupMusic()
                    self.setUpAliens()
                    self.setUpAsteroids()
                }
                run(SKAction.sequence([wait,action]))
            }
            sprite.removeFromParent()
        }
    }

    
    func processUserMotion(forUpdate currentTime: CFTimeInterval) {
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            if let data = motionManager.accelerometerData {
                if data.acceleration.x > 0.001 {
                    //player.physicsBody!.applyForce(CGVector(dx: 30 * CGFloat(data.acceleration.x), dy: 0))
                    //player.physicsBody?.velocity.dx = CGFloat(120 * ((data.acceleration.x * 10) * (data.acceleration.x * 1.25)))
                    // Disabled Acceleration
                    player.physicsBody?.velocity.dx = CGFloat(120 * (data.acceleration.x * 10))
                }
                if data.acceleration.x < -0.001 {
                    //player.physicsBody!.applyForce(CGVector(dx: 30 * CGFloat(data.acceleration.x), dy: 0))
                    //player.physicsBody?.velocity.dx = CGFloat(120 * ((data.acceleration.x * 10) * (data.acceleration.x * -1.25)))
                    // Disabled Acceleration
                    player.physicsBody?.velocity.dx = CGFloat(120 * (data.acceleration.x * 10))
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if setStartBool {
            startTime = currentTime
            setStartBool = false
        }
        
        processUserMotion(forUpdate: currentTime)
        GameData.shared.playerScore = GameData.shared.playerScore + 1
        updateHud()
        let timeSinceLastFired = currentTime - lastFiredTime
        // Only fire weapon if the weapon hasn't been fired in the last fireRate seconds and the user is touching the screen
        if timeSinceLastFired > fireRate && touchingScreen && playerAlive {
            firePlayerWeapon()
            lastFiredTime = currentTime
        }
        
        // Sets all nodes damaged by explosion to be able to be damaged again.
        for child in self.children {
            if child.name != nil && damagedByPlayerMissileExplosionArray.contains(child.name!){
                child.userData?.setValue(false, forKey: "invulnerable")
            }
        }
        
        
        // Spawns the first boss eyeBoss, if it hasn't been spawned before and enough time has passed
        if (currentTime - startTime) >= timeToSpawnEyeBoss && !eyeBossSpawned {
            setUpEyeBoss()
        }
        
        // eyeBoss moves and attacks after it has finished moving into position and has its physics body initialized
        if eyeBossFullySpawned {
            processEyeBossMovement(forUpdate: currentTime)
            // CHANGE EYEBOSS ATTACK RATE.
            if(currentTime - timeEyeBossAttack) >= eyeBossAttackRate {
                timeEyeBossAttack = currentTime
                processEyeBossAttacks(attackChosen: Int(arc4random_uniform(2) + 1))
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingScreen = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingScreen = false
    }
    
    // Called when there is a collision between two nodes.
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
        
        if ob1.name == kPlayerName && ob2.name == kEyeBossLaserName {
            playerTakesDamage(damage: 10, view: view!)
        }
        
        if ob1.name == kPlayerName && ob2.name == kEyeBossName {
            playerTakesDamage(damage: 80, view: view!)
        }
        
        if ob1.name == kPlayerName && ob2.name == kHealthPackName {
            //TODO: Heal sound effect
            ob2.removeFromParent()
            GameData.shared.playerHealth = GameData.shared.maxPlayerHealth
        }
        
        if ob1.name == kPlayerName && ob2.name == kFireRateUpgradeName {
            //TODO: reloading sound effect
            ob2.removeFromParent()
            fireRateUpgradeNumber = fireRateUpgradeNumber + 1
            setupWeapon()
        }
        
        if ob1.name == kPlayerName && ob2.name == kThreeShotUpgradeName {
            ob2.removeFromParent()
            if threeShotUpgrade {
                fiveShotUpgrade = true
            }
            threeShotUpgrade = true
        }
        
        if damagedByPlayerLaserArray.contains(ob1.name!) && ob2.name == kLaserName {
            subtractHealth(sprite: ob1, damage: 1)
            ob2.removeFromParent()
        }
        
        if damagedByPlayerMissileArray.contains(ob1.name!) && ob2.name == kMissileName {
            subtractHealth(sprite: ob1, damage: 1)
            ob2.removeFromParent()
            missileExplosion(missile: ob2)
            missileExplosionEffect(position: ob2.position)
        }
        
        if damagedByPlayerMissileExplosionArray.contains(ob1.name!) && ob2.name == kMissileExplosionName && ob1.userData?.value(forKey: "invulnerable") as? Bool != true {
            ob1.userData?.setValue(true, forKey: "invulnerable")
            subtractHealth(sprite: ob1, damage: 4)
        }
        
        if ob1.name == kEyeBossLaserName && ob2.name == kMissileName {
            ob2.removeFromParent()
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
        
        if nodeA.name == kEyeBossName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kEyeBossName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kEyeBossLaserName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kEyeBossLaserName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
    }
    
}
