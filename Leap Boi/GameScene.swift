//
//  GameScene.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-02-26.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//  Music from: 

// TODO:
// TOP PRIORITY: In-app payments, fix for different size devices, Make boss2 aggro very slightly further apart, make laser slightly quieter
// Make upgradeTimer where increase droprate if no upgrades in x time?
// Centre eyeBossLaster better..
// Change player default look -> Button in the store to go to cosmetic upgrades
// Add option on startScene to change look
// Change eyeboss image..
// Add stats like "Damage" "Fire Rate" etc under each weapon on WeaponScene
// add purchasable(with credits) weapons, upgrades, speed upgrades, bullet speed upgrades - Revive for credits
// inapp purchases for cosmetics
// inapp purchases to get credits
// Add achievements: 8 enemies killed with one explosion, achievement for beating each boss,
// Upgrades: Diagonal bullets, DOT fire, freeze weapon?, Nuke
// Power up icons: https://www.gamedevmarket.net/asset/asteroids-crusher-game-assets-3793/
// Improve HUD- show upgrades
// Make sound and animation for gaining credits, rain coins down
// Make bosses spawn randomly? When you kill enough get to fight final boss
// - Random boss mode?
// Coin Chest drop which grants a lot of credits?
// credit sprites and music creators
// Music from https://itch.io/game-assets/tag-music


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

let Pi = CGFloat(Double.pi)
let DegreesToRadians = Pi / 180
let RadiansToDegrees = 180 / Pi


extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

public extension CGFloat {
    /// Randomly returns either 1.0 or -1.0.
    public static var randomSign: CGFloat {
        return (arc4random_uniform(2) == 0) ? 1.0 : -1.0
    }
}

extension SKSpriteNode {
    func addGlow(radius: Float = 20) {
        let effectNode = SKEffectNode()
        effectNode.name = "glow"
        effectNode.shouldRasterize = true
        addChild(effectNode)
        effectNode.addChild(SKSpriteNode(texture: texture))
        effectNode.filter = CIFilter(name: "CIGaussianBlur", withInputParameters: ["inputRadius":radius])
    }
    
    func removeGlow() {
        for child in children {
            if child.name != nil && child.name == "glow" {
                child.removeFromParent()
            }
        }
    }
}

// Collision bitmasks for all objects
struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0x1 << 1
    static let Enemy: UInt32 = 0x1 << 2
    static let PlayerProjectile: UInt32 = 0x1 << 3
    static let MissileExplosion: UInt32 = 0x1 << 4
    static let AlienLaser: UInt32 = 0x1 << 5
    static let UpgradePack: UInt32 = 0x1 << 6
    static let EyeBossLaserAttack: UInt32 = 0x1 << 7
    static let AlienMissile: UInt32 = 0x1 << 8
    static let Shield: UInt32 = 0x1 << 9
    static let Plasma: UInt32 = 0x1 << 10
    static let HeavyAlien: UInt32 = 0x1 << 11
    static let Boss3: UInt32 = 0x1 << 12
    static let Harvester: UInt32 = 0x1 << 13
    static let BloodProjectile: UInt32 = 0x1 << 14
    
    static let Edge: UInt32 = 0x1 << 25
    static let All: UInt32 = UInt32.max
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
    let kMassiveAsteroidName = "massiveAsteroid"
    let kLargeAsteroidName = "largeAsteroid"
    let kMediumAsteroidName = "mediumAsteroid"
    let kSmallAsteroidName = "smallAsteroid"
    let kAlienCruiserName = "alienCruiser"
    let kAlienMissileName = "alienMissile"
    let kLaserName = "laser"
    let kMissileName = "missile"
    let kHomingMissileName = "homingMissile"
    let kMissileExplosionName = "missileExplosion"
    let kHealthPackName = "healthPack"
    let kFireRateUpgradeName = "firerateUpgrade"
    let kThreeShotUpgradeName = "threeShotUpgrade"
    let kProtectiveShieldUpgradeName = "protectiveShieldUpgrade"
    let kProtectiveShieldName = "protectiveShield"
    let kHomingMissileUpgradeName = "homingMissileUpgrade"
    let kLaserDamageUpgradeName = "laserDamageUpgrade"
    let kMissileExplosionDamageUpgradeName = "missileExplosionDamageUpgrade"
    let kMissileExplosionSizeUpgradeName = "missileExplosionSizeUpgrade"
    let kEyeBossName = "eyeBoss"
    let kEyeBossLaserName = "eyeBossLaser"
    let kEyeBossLaserChargeName = "eyeBossLaserCharge"
    let kLittleEyeName = "littleEye"
    let kBoss2Name = "boss2"
    let kPlasmaName = "plasma"
    let kHeavyAlienName = "heavyAlien"
    let kBoss3Phase1Name = "boss3phase1"
    let kBoss3Phase2Name = "boss3phase2"
    let kHarvesterName = "harvester"
    let kBloodProjectileName = "bloodProjectile"
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    let kPauseHolderName = "pauseHolder"
    let kPauseLabelName = "pauseLabel"
    let kUnpauseButtonName = "unpauseButton"
    let kMuteButtonName = "muteButton"
    let kRetryButtonName = "retryButton"
    let kMenuButtonName = "menuButton"
    var scoreLabel = SKLabelNode(fontNamed: "SquareFont")
    var healthLabel = SKLabelNode(fontNamed: "SquareFont")
    var pauseButton: SKSpriteNode! = nil
    var pauseHolder: SKSpriteNode! = nil
    var unpauseButton: SKSpriteNode! = nil
    var muteButton: SKSpriteNode! = nil
    var gameMuted = false
    var retryButton: SKSpriteNode! = nil
    var menuButton: SKSpriteNode! = nil
    
    // Background
    let background1 = SKSpriteNode(imageNamed: "bg1")
    let background2 = SKSpriteNode(imageNamed: "bg1")
    
    
    // Player Variables
    // Starts with the screen not being pressed
    private var touchingScreen = false
    // Shoots every x seconds
    var fireRate = 0.3
    // The players weapon choice
    var playerWeapon = ""
    // Base damage of weapons
    var laserBaseDamage = 1.0
    var missileBaseDamage = 1.0
    var homingMissileBaseDamage = 1.0
    var missileExplosionBaseDamage = 6.0
    // Health and Shield upgrade values
    var healthPerHealthUpgrade = 20
    var shieldHealthPerUpgrade = 20
    // Invulnerable right after getting hit
    var playerTempInvulnerable = false
    // player moves right when tilting right if direction is 1, vice versa
    var playerMovingDirection = 1
    // The number of fireRate upgrades
    private var fireRateUpgradeNumber = 0
    // The number of laserDamage upgrades
    private var laserDamageUpgradeNumber = 0.0
    // The number of missile explosion upgrades
    private var missileExplosionDamageUpgradeNumber = 0.0
    // The number of missile explosion size upgrades
    private var largerExplosionUpgradeNumber = 0.0
    // All the possible upgrades
    private var twoShotUpgrade = false
    private var threeShotUpgrade = false
    private var fourShotUpgrade = false
    private var fiveShotUpgrade = false
    private var protectiveShieldActive = false
    private var numberOfHomingMissileUpgrades = 0
    // Time since last fired
    private var lastFiredTime: CFTimeInterval = 0
    // Array of homingMissiles
    private var homingMissileArray: [SKSpriteNode] = []
    
    

    // Timer for the game- is the number of seconds * 60
    private var timeCounter = 0.0
    
    // Enemy Variables
    private var alienTriShotActive = false
    private var alienMissileArray: [SKSpriteNode] = []
    
    // BossVariables
    // How long a player must play before each boss spawns in seconds * 60
    private var timeToSpawnNextBoss = 6000.0 // 100 Seconds
    // When each boss is defeated
    private var timeEyeBossDefeated: TimeInterval = 0.0
    private var timeBoss2Defeated: TimeInterval = 0.0
    private var timeBoss3Defeated: TimeInterval = 0.0
    
    // Each boss starts unspawned and undefeated
    private var eyeBossSpawned = false
    private var eyeBossFullySpawned = false
    private var eyeBossDefeated = false
    private var boss2Spawned = false
    private var boss2FullySpawned = false
    private var boss2Defeated = false
    private var boss3Spawned = false
    private var boss3FullySpawned = false
    private var boss3Defeated = false
    private var boss3Phase1 = false
    private var boss3Phase2 = false
    // Attack rate of each boss- seconds between each attack
    private var eyeBossAttackRate = 5.0
    private var boss2AttackRate = 5.0
    private var boss3AttackRate = 5.0
    // Time each boss attacked last
    private var timeEyeBossAttack: CFTimeInterval = 0
    private var timeBoss2Attack: CFTimeInterval = 0
    private var timeBoss3Attack: CFTimeInterval = 0
    
    private var numberHeavyAlienKilled = 0
    
    // Score for killing each enemy
    let alienKillScore = 30
    let massiveAsteroidKillScore = 1000
    let largeAsteroidKillScore = 90
    let mediumAsteroidKillScore = 50
    let smallAsteroidKillScore = 20
    let alienCruiserKillScore = 500
    let eyeBossKillScore = 5000 // Boss1
    let littleEyeKillScore = 50
    let boss2killScore = 10000 // Boss2
    let heavyAlienKillScore = 2500
    let boss3KillScore = 20000 // Boss3
    let harvesterKillScore = 30
    
    
    var damagedByPlayerLaserArray: [String] = []
    var damagedByPlayerMissileArray: [String] = []
    var damagedByPlayerMissileExplosionArray: [String] = []
    
    var allPossibleEnemies: [String] = []
    
    
    static var sharedInstance = GameScene()
    let motionManager = CMMotionManager()
    
    // Called on Scene load
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        let runStartSound = SKAction.run {
            GameData.shared.bgMusicPlayer.stop()
            self.startSoundFile()
        }
        let wait = SKAction.wait(forDuration: 5.0)
        let runMusic = SKAction.run {
            self.setupMusic(music: "Race to Mars", type: "mp3")
        }
        run(SKAction.sequence([runStartSound, wait, runMusic]))
        
        setupDamageArrays()
        setupScreen()
        setupBackground()
        setupWeapon()
        setupPlayer()
        setupStartEnemies()
        setupHud()
        setUpUpgrades()
        motionManager.startAccelerometerUpdates()
        GameScene.sharedInstance = self
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.8)
    }
    
    func startSoundFile() {
        let audioNode = SKAudioNode(fileNamed: "start-level")
        audioNode.autoplayLooped = false
        self.addChild(audioNode)
        let playAction = SKAction.play()
        audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 5), SKAction.removeFromParent()]))
    }
    
    func setupDamageArrays(){
        damagedByPlayerLaserArray = [kAlienName, kMassiveAsteroidName, kLargeAsteroidName, kMediumAsteroidName, kSmallAsteroidName, kAlienCruiserName, kLittleEyeName, kEyeBossName, kBoss2Name, kHeavyAlienName, kBoss3Phase1Name, kHarvesterName, kBoss3Phase2Name]
        damagedByPlayerMissileArray = [kAlienName, kMassiveAsteroidName, kLargeAsteroidName, kMediumAsteroidName, kSmallAsteroidName, kAlienCruiserName, kLittleEyeName, kEyeBossName, kBoss2Name, kHeavyAlienName, kBoss3Phase1Name, kHarvesterName, kBoss3Phase2Name]
        damagedByPlayerMissileExplosionArray = [kAlienName, kMassiveAsteroidName, kLargeAsteroidName, kMediumAsteroidName, kSmallAsteroidName, kAlienCruiserName, kLittleEyeName, kEyeBossName, kBoss2Name, kHeavyAlienName, kBoss3Phase1Name, kHarvesterName, kBoss3Phase2Name]
        
        allPossibleEnemies = [kAlienName, kMassiveAsteroidName, kLargeAsteroidName, kMediumAsteroidName, kSmallAsteroidName, kAlienCruiserName, kLittleEyeName, kEyeBossName, kBoss2Name, kHeavyAlienName, kBoss3Phase1Name, kHarvesterName, kBoss3Phase2Name]
    }
    
    func setupScreen() {
        //scene?.scaleMode = .aspectFit
        scene?.scaleMode = SKSceneScaleMode.resizeFill
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        //self.physicsBody!.usesPreciseCollisionDetection = true
        self.physicsBody!.categoryBitMask = PhysicsCategory.Edge
        self.physicsBody?.contactTestBitMask = PhysicsCategory.None
        self.physicsBody?.collisionBitMask = PhysicsCategory.Player
    }
    
    func setupBackground() {
        background1.anchorPoint = CGPoint(x: 0, y: 0)
        background1.position = CGPoint(x: 0, y: 0)
        background1.zPosition = -15
        self.addChild(background1)
        
        background2.anchorPoint = CGPoint(x: 0, y: 0)
        background2.position = CGPoint(x: 0, y: background1.size.height - 1)
        background2.zPosition = -15
        self.addChild(background2)
    }
    
    func updateBackground() {
        background1.position = CGPoint(x: background1.position.x, y: background1.position.y - 1)
        background2.position = CGPoint(x: background2.position.x, y: background2.position.y - 1)
        
        if(background1.position.y < 0 - background1.size.height)
        {
            background1.position = CGPoint(x: background2.position.x, y: background2.position.y + background2.size.height )
        }
        
        if(background2.position.y < 0 - background2.size.height)
        {
            background2.position = CGPoint(x: background1.position.x, y: background1.position.y + background1.size.height)
        }
    }
    
    func setupMusic(music: String, type: String) {
        if gameMuted {
            return
        }
        let path = Bundle.main.path(forResource: music, ofType: type)!
        let url = URL(fileURLWithPath: path)
        do {
            GameData.shared.bgMusicPlayer = try AVAudioPlayer(contentsOf: url)
            GameData.shared.bgMusicPlayer.numberOfLoops = -1
            GameData.shared.bgMusicPlayer.prepareToPlay()
        } catch let error as NSError {
            print(error.description)
        }
        GameData.shared.bgMusicPlayer.play()
        GameData.shared.playingMenuMusic = false
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
            fireRate = BaseFireRate.Laser * pow(0.9, min(Double(fireRateUpgradeNumber), 7))
            playerWeapon = kLaserName
        case "missile":
            fireRate = BaseFireRate.Missile * pow(0.9, min(Double(fireRateUpgradeNumber), 7))
            playerWeapon = kMissileName
        default:
            fireRate = 1
        }
    }
    
    func setupStartEnemies() {
        setUpAliens(min: 0.2, max: 0.8)
        setUpAsteroids(min: 4, max: 12)
        addPowerUp(position: CGPoint(x: size.width/2, y: 200), image: "firerateupgrade", name: kFireRateUpgradeName)
        addPowerUp(position: CGPoint(x: size.width/2, y: 200), image: "firerateupgrade", name: kFireRateUpgradeName)
        addPowerUp(position: CGPoint(x: size.width/2, y: 200), image: "firerateupgrade", name: kFireRateUpgradeName)
        addPowerUp(position: CGPoint(x: size.width/2, y: 200), image: "firerateupgrade", name: kFireRateUpgradeName)
        addPowerUp(position: CGPoint(x: size.width/2, y: 200), image: "firerateupgrade", name: kFireRateUpgradeName)
        addPowerUp(position: CGPoint(x: size.width/2, y: 200), image: "firerateupgrade", name: kFireRateUpgradeName)
        addPowerUp(position: CGPoint(x: size.width/2, y: 200), image: "firerateupgrade", name: kFireRateUpgradeName)
        addPowerUp(position: CGPoint(x: size.width/2, y: 200), image: "firerateupgrade", name: kFireRateUpgradeName)
        //setUpEyeBoss()
        //setUpBoss2()
        //setUpBoss3()
        //setUpAlienCruisers(min: 1, max: 5)
        //setUpSpawnLittleEyes(min: 1, max: 1)
    }
    
    func setupHud() {
        scoreLabel.name = kScoreHudName
        scoreLabel.fontName = "SquareFont"
        scoreLabel.fontSize = 15
        scoreLabel.fontColor = SKColor.white
        scoreLabel.text = String("Score: \(GameData.shared.playerScore)")
        scoreLabel.position = CGPoint(
            x: 0,
            y: size.height - scoreLabel.frame.size.height
        )
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        healthLabel.name = kHealthHudName
        healthLabel.fontName = "SquareFont"
        healthLabel.fontSize = 15
        healthLabel.fontColor = SKColor.green
        healthLabel.text = String("Health: \(GameData.shared.playerHealth)%")
        healthLabel.position = CGPoint(
            x: 0,
            y: size.height - (20 + healthLabel.frame.size.height/2)
        )
        healthLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        healthLabel.zPosition = 20
        addChild(healthLabel)
        
        createPauseButton()
    }
    
    func createPauseButton() {
        pauseButton = SKSpriteNode(imageNamed: "pause")
        pauseButton.size = CGSize(width: 30, height: 30)
        pauseButton.zPosition = 50
        pauseButton.position = CGPoint(x: size.width - pauseButton.size.width, y: size.height - pauseButton.size.height)
        addChild(pauseButton)
    }
    
    func createPauseNode() {
        pauseHolder = SKSpriteNode(imageNamed: "horizontal-fullscreen-button-holder-without-buttons")
        pauseHolder.name = kPauseHolderName
        pauseHolder.zPosition = 9
        pauseHolder.size = CGSize(width: 333, height: 226.6)
        pauseHolder.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        addChild(pauseHolder)
        createPauseLabel()
        createUnpauseButton()
        createMuteButton()
        createRetryButton()
        createMenuButton()
    }
    
    func removePauseNode() {
        let nodesToRemove = [kPauseHolderName, kPauseLabelName, kMenuButtonName, kUnpauseButtonName, kRetryButtonName, kMuteButtonName]
        for child in children {
            if child.name != nil && nodesToRemove.contains(child.name!) {
                child.removeFromParent()
            }
        }
    }
    
    func createPauseLabel() {
        let pauseLabel = SKLabelNode(fontNamed: "SquareFont")
        pauseLabel.name = kPauseLabelName
        pauseLabel.zPosition = 10
        pauseLabel.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        pauseLabel.text = "Game Paused"
        pauseLabel.fontSize = 35
        addChild(pauseLabel)
    }
    
    func createUnpauseButton() {
        unpauseButton = SKSpriteNode(imageNamed: "play")
        unpauseButton.name = kUnpauseButtonName
        unpauseButton.zPosition = 10
        unpauseButton.size = CGSize(width: 51.2, height: 51.2)
        unpauseButton.position = CGPoint(x: size.width * 0.5 - pauseHolder.size.width * 0.25975, y: size.height * 0.5 - pauseHolder.size.height/2 + 22)
        addChild(unpauseButton)
    }
    
    func createMuteButton() {
        muteButton = SKSpriteNode(imageNamed: "")
        muteButton.name = kMuteButtonName
        if gameMuted {
            muteButton.texture = SKTexture(imageNamed: "sound-off")
        } else {
            muteButton.texture = SKTexture(imageNamed: "sound-on")
        }
        muteButton.zPosition = 10
        muteButton.size = CGSize(width: 51.2, height: 51.2)
        muteButton.position = CGPoint(x: size.width * 0.5 - pauseHolder.size.width * 0.086786, y: size.height * 0.5 - pauseHolder.size.height/2 + 22)
        addChild(muteButton)
    }
    
    func createRetryButton() {
        retryButton = SKSpriteNode(imageNamed: "retry")
        retryButton.name = kRetryButtonName
        retryButton.zPosition = 10
        retryButton.size = CGSize(width: 51.2, height: 51.2)
        retryButton.position = CGPoint(x: size.width * 0.5 + pauseHolder.size.width * 0.086786, y: size.height * 0.5 - pauseHolder.size.height/2 + 22)
        addChild(retryButton)
    }
    
    func createMenuButton() {
        menuButton = SKSpriteNode(imageNamed: "menu")
        menuButton.name = kMenuButtonName
        menuButton.zPosition = 10
        menuButton.size = CGSize(width: 51.2, height: 51.2)
        menuButton.position = CGPoint(x: size.width * 0.5 + pauseHolder.size.width * 0.25975, y: size.height * 0.5 - pauseHolder.size.height/2 + 22)
        addChild(menuButton)
    }
    
    func updateHud(){
        healthLabel.text = String("Health: \(GameData.shared.playerHealth)%")
        scoreLabel.text = String("Score: \(GameData.shared.playerScore)")
    }
    
    func makePlayer() -> SKNode {
        let player = SKSpriteNode(imageNamed: "PlayerShip_\(GameData.shared.shipColourChosen)")
        player.size = CGSize(width: 35, height: 35)
        player.zPosition = 6
        player.name = kPlayerName
        
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size - CGSize(width: 5, height: 5))
        player.physicsBody!.isDynamic = true
        player.physicsBody!.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.AlienLaser | PhysicsCategory.EyeBossLaserAttack | PhysicsCategory.AlienMissile | PhysicsCategory.Enemy
        player.physicsBody?.collisionBitMask = PhysicsCategory.Edge
        GameData.shared.maxPlayerHealth = 100 + healthPerHealthUpgrade * GameData.shared.numberOfHealthUpgrades
        GameData.shared.playerHealth = GameData.shared.maxPlayerHealth
        return player
    }
    
    func setUpUpgrades() {
        if GameData.shared.doubleLaserUpgrade {
            twoShotUpgrade = true
        }
        if GameData.shared.homingMissileUpgrade && playerWeapon == kMissileName {
            numberOfHomingMissileUpgrades = 1
            setUpHomingMissile()
        }
    }

    
    // Basic Enemies
    func setUpAliens(min: CGFloat, max: CGFloat) {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addAlien),
                SKAction.wait(forDuration: Double(random(min: CGFloat(min), max: CGFloat(max))))
                ])
        ))
    }
    
    func addAlien() {
        let alien = SKSpriteNode(imageNamed: "alien")
        alien.name = kAlienName
        alien.size = CGSize(width: 35, height: 39.4)
        alien.userData = NSMutableDictionary()
        alien.userData?.setValue(false, forKey: "isDead")
        setAlienHealth(alien: alien)
        
        alien.physicsBody = SKPhysicsBody(texture: alien.texture!, size: alien.size)
        alien.physicsBody?.isDynamic = false
        alien.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        alien.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Shield
        alien.physicsBody?.collisionBitMask = PhysicsCategory.None
        alien.zPosition = 1
        
        let actualX = random(min: alien.size.width/2, max: size.width - alien.size.width/2)
        alien.position = CGPoint(x: actualX, y: size.height + alien.size.height/2)
        addChild(alien)
        
        let actualDuration = random(min: CGFloat(7.0), max: CGFloat(10.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -alien.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        alien.run(SKAction.sequence([actionMove, actionMoveDone]))
        setUpAlienLaser(alien: alien)
    }
    
    func addAlienLaser(alien: SKSpriteNode, offset: CGFloat) {
        //let alienLaser = SKSpriteNode(color: SKColor.green, size: CGSize(width: 2, height: 12))
        let alienLaser = SKSpriteNode(imageNamed: "Bullet_Green_Laser")
        alienLaser.size = CGSize(width: 16, height: 16)
        alienLaser.name = kAlienLaserName
        alienLaser.zPosition = 4
        alienLaser.zRotation = DegreesToRadians * 180
        
        alienLaser.physicsBody = SKPhysicsBody(rectangleOf: alienLaser.size)
        alienLaser.physicsBody?.isDynamic = false
        alienLaser.physicsBody?.categoryBitMask = PhysicsCategory.AlienLaser
        alienLaser.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Shield
        alienLaser.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualDuration = random(min: CGFloat(4.0), max: CGFloat(5.0))
        alienLaser.position = alien.position - CGPoint(x: 0, y: alien.size.height/2 + alienLaser.size.height/2)
        let actionMove = SKAction.move(to: CGPoint(x: alienLaser.position.x + offset, y: alienLaser.position.y - 1000), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        alienLaser.run(SKAction.sequence([actionMove, actionMoveDone]))
        addChild(alienLaser)
    }
    
    func setUpAlienLaser(alien: SKSpriteNode) {
        let wait = SKAction.wait(forDuration: Double(random(min: CGFloat(1), max: CGFloat(8))))
        let run = SKAction.run {
            self.addAlienLaser(alien: alien, offset: 0)
            if self.alienTriShotActive {
                self.addAlienLaser(alien: alien, offset: 300)
                self.addAlienLaser(alien: alien, offset: -300)
            }
        }
        alien.run(SKAction.repeatForever(SKAction.sequence([wait, run])))
    }
    
    // Make a projectile which moves in the direction it is facing
    func addAoeLaser(position: CGPoint, rotation: CGFloat, image: String) {
        let laser = SKSpriteNode(imageNamed: image)
        laser.name = kAlienLaserName
        laser.zPosition = 4
        laser.size = CGSize(width: 32, height: 32)
        laser.position = position
        laser.zRotation = rotation
        
        laser.physicsBody = SKPhysicsBody(texture: laser.texture!, size: laser.size - CGSize(width: 5, height: 5))
        laser.physicsBody?.isDynamic = true
        laser.physicsBody?.affectedByGravity = false
        laser.physicsBody?.categoryBitMask = PhysicsCategory.AlienLaser
        laser.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Shield
        laser.physicsBody?.collisionBitMask = PhysicsCategory.None
        laser.physicsBody?.usesPreciseCollisionDetection = true
        laser.physicsBody?.velocity = CGVector(dx: 200 * cos(laser.zRotation), dy: 200 * sin(laser.zRotation))
        
        let actionWait = SKAction.wait(forDuration: 5)
        let actionWaitDone = SKAction.removeFromParent()
        laser.run(SKAction.sequence([actionWait, actionWaitDone]))
        addChild(laser)
    }

    func setUpAsteroids(min: CGFloat, max: CGFloat) {
        let actionRun = SKAction.run {
            self.addLargeAsteroid(position: CGPoint(x:random(min: 0, max: self.size.width), y: self.size.height * 1.2), xoffset: 0, yoffset: 0)
        }
        
        run(SKAction.repeatForever(
            SKAction.sequence([actionRun,
                SKAction.wait(forDuration: Double(random(min: CGFloat(min), max: CGFloat(max))))
                ])
        ))
    }
    
    func setUpMassiveAsteroids(min: CGFloat, max: CGFloat) {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.wait(forDuration: Double(random(min: CGFloat(min), max: CGFloat(max)))),
                SKAction.run(addMassiveAsteroid)
                ])
        ))
    }
    
    func addMassiveAsteroid() {
        let asteroid = SKSpriteNode(imageNamed: "Meteor_Big")
        asteroid.name = kMassiveAsteroidName
        asteroid.size = CGSize(width: 280, height: 280)
        asteroid.userData = NSMutableDictionary()
        asteroid.userData?.setValue(false, forKey: "isDead")
        setMassiveAsteroidHealth(asteroid: asteroid)
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.isDynamic = false
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Shield
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let oneRevolution:SKAction = SKAction.rotate(byAngle: CGFloat.pi * 2 * CGFloat.randomSign, duration: TimeInterval(random(min: 12, max: 14)))
        let repeatRotation:SKAction = SKAction.repeatForever(oneRevolution)
        asteroid.run(repeatRotation)
        
        let actualX = random(min: asteroid.size.width/2, max: size.width - asteroid.size.width/2)
        asteroid.position = CGPoint(x: actualX, y: size.height + asteroid.size.height/2)
        addChild(asteroid)
        
        let actualDuration = random(min: CGFloat(20.0), max: CGFloat(25.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: random(min: asteroid.size.width/2, max: size.width - asteroid.size.width/2), y: -asteroid.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addLargeAsteroid(position: CGPoint, xoffset: CGFloat, yoffset: CGFloat) {
        let asteroid = SKSpriteNode(imageNamed: "Meteor_Big")
        asteroid.name = kLargeAsteroidName
        asteroid.size = CGSize(width: 80, height: 80)
        asteroid.userData = NSMutableDictionary()
        asteroid.userData?.setValue(false, forKey: "isDead")
        setLargeAsteroidHealth(asteroid: asteroid)
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.isDynamic = false
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Shield
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let oneRevolution:SKAction = SKAction.rotate(byAngle: CGFloat.pi * 2 * CGFloat.randomSign, duration: TimeInterval(random(min: 6, max: 10)))
        let repeatRotation:SKAction = SKAction.repeatForever(oneRevolution)
        asteroid.run(repeatRotation)
        
        asteroid.position = position + CGPoint(x: xoffset, y: yoffset)
        addChild(asteroid)
        
        let actualDuration = random(min: CGFloat(12.0), max: CGFloat(15.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: random(min: asteroid.size.width/2, max: size.width - asteroid.size.width/2), y: -asteroid.size.height/2), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addMediumAsteroid(position: CGPoint, xoffset: CGFloat) {
        let asteroid = SKSpriteNode(imageNamed: "Meteor_Medium")
        asteroid.name = kMediumAsteroidName
        asteroid.size = CGSize(width: 40, height: 40)
        asteroid.userData = NSMutableDictionary()
        asteroid.userData?.setValue(false, forKey: "isDead")
        setMediumAsteroidHealth(asteroid: asteroid)
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.isDynamic = false
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Shield
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.None
        let oneRevolution:SKAction = SKAction.rotate(byAngle: CGFloat.pi * 2 * CGFloat.randomSign, duration: TimeInterval(random(min: 3, max: 5)))
        let repeatRotation:SKAction = SKAction.repeatForever(oneRevolution)
        asteroid.run(repeatRotation)

        asteroid.position = position + CGPoint(x: xoffset, y: 0)
        addChild(asteroid)
        
        let actualDuration = random(min: CGFloat(12.0), max: CGFloat(15.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: random(min: asteroid.size.width/2, max: size.width - asteroid.size.width/2), y: position.y - size.height), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addSmallAsteroid(position: CGPoint, xoffset: CGFloat) {
        let asteroid = SKSpriteNode(imageNamed: "Meteor_Small")
        asteroid.name = kSmallAsteroidName
        asteroid.size = CGSize(width: 20, height: 20)
        asteroid.userData = NSMutableDictionary()
        asteroid.userData?.setValue(false, forKey: "isDead")
        setSmallAsteroidHealth(asteroid: asteroid)
        
        asteroid.physicsBody = SKPhysicsBody(texture: asteroid.texture!, size: asteroid.size)
        asteroid.physicsBody?.isDynamic = false
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Shield
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.None
        let oneRevolution:SKAction = SKAction.rotate(byAngle: CGFloat.pi * 2 * CGFloat.randomSign, duration: TimeInterval(random(min: 1, max: 3)))
        let repeatRotation:SKAction = SKAction.repeatForever(oneRevolution)
        asteroid.run(repeatRotation)
        
        asteroid.position = position + CGPoint(x: xoffset, y: 0)
        addChild(asteroid)
        
        let actualDuration = random(min: CGFloat(12.0), max: CGFloat(15.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: random(min: asteroid.size.width/2, max: size.width - asteroid.size.width/2), y: position.y - size.height), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        asteroid.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func setUpAlienCruisers(min: CGFloat, max: CGFloat) {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addAlienCruiser),
                SKAction.wait(forDuration: Double(random(min: CGFloat(min), max: CGFloat(max))))
                ])
        ))
    }
    
    func addAlienCruiser() {
        let alienCruiser = SKSpriteNode(imageNamed: "alienCruiser")
        alienCruiser.name = kAlienCruiserName
        alienCruiser.zPosition = 3
        alienCruiser.size = CGSize(width: 80, height: 100)
        alienCruiser.userData = NSMutableDictionary()
        alienCruiser.userData?.setValue(false, forKey: "isDead")
        setAlienCruiserHealth(alienCruiser: alienCruiser)
        
        alienCruiser.physicsBody = SKPhysicsBody(texture: alienCruiser.texture!, size: alienCruiser.size)
        alienCruiser.physicsBody?.isDynamic = false
        alienCruiser.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        alienCruiser.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Shield
        alienCruiser.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualX = random(min: alienCruiser.size.width/2, max: size.width - alienCruiser.size.width/2)
        alienCruiser.position = CGPoint(x: actualX, y: size.height + alienCruiser.size.height/2)
        addChild(alienCruiser)
        setUpAlienCruiserBehaviour(alienCruiser: alienCruiser)
    }
    
    func setUpAlienCruiserBehaviour(alienCruiser: SKSpriteNode) {
        let wait = SKAction.wait(forDuration: Double(random(min: CGFloat(3), max: CGFloat(5))))
        let randomX = random(min: alienCruiser.size.width/2, max: size.width - alienCruiser.size.width/2)
        let randomY = random(min: size.height/3, max: size.height - alienCruiser.size.height/2)
        let locationToMoveTo = CGPoint(x: randomX, y: randomY)
        let opposite = (locationToMoveTo.y - alienCruiser.position.y)
        let adjacent = (locationToMoveTo.x - alienCruiser.position.x)
        let distanceOfLocationToMoveTo = sqrtf(powf(Float(opposite), 2.0) + powf(Float(adjacent), 2.0))
        let angleToRotateTo = angleToRotateToWhileFacingDown(adjacent: adjacent, opposite: opposite)
        let turn1 = SKAction.rotate(toAngle: angleToRotateTo, duration: 1)
        let move = SKAction.sequence([SKAction.run {alienCruiser.texture = SKTexture(imageNamed: "alienCruiserMoving")}, SKAction.move(to: locationToMoveTo, duration: TimeInterval(distanceOfLocationToMoveTo/120))])
        let changeImageBack = SKAction.run {alienCruiser.texture = SKTexture(imageNamed: "alienCruiser")}
        let turn2 = SKAction.rotate(toAngle: 0, duration: 1)
        let fire = SKAction.run {
            self.addAlienCruiserMissile(alienCruiser: alienCruiser, offset: -20)
            self.addAlienCruiserMissile(alienCruiser: alienCruiser, offset: 20)
        }
        alienCruiser.run(SKAction.sequence([wait, turn1, move, changeImageBack, turn2, fire]), completion: { () -> Void in
            self.setUpAlienCruiserBehaviour(alienCruiser: alienCruiser)
        })
    }

    func addAlienCruiserMissile(alienCruiser: SKSpriteNode, offset: CGFloat) {
        let alienMissile = SKSpriteNode(imageNamed: "alienMissile")
        alienMissile.size = CGSize(width: 11, height: 11)
        alienMissile.name = kAlienMissileName
        alienMissile.zPosition = 5
        
        alienMissile.physicsBody = SKPhysicsBody(texture: alienMissile.texture!, size: alienMissile.size)
        alienMissile.physicsBody?.isDynamic = true
        alienMissile.physicsBody?.affectedByGravity = false
        alienMissile.physicsBody?.categoryBitMask = PhysicsCategory.AlienMissile
        alienMissile.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Shield
        alienMissile.physicsBody?.collisionBitMask = PhysicsCategory.AlienMissile
        alienMissile.physicsBody?.usesPreciseCollisionDetection = true

        alienMissile.position = alienCruiser.position - CGPoint(x: -offset, y: alienCruiser.size.height/3)
        alienMissile.physicsBody?.velocity.dy = -200
        addChild(alienMissile)
        alienMissileArray.append(alienMissile)
    }
    
    func processAlienMissileMovement() {
        for alienMissile in alienMissileArray {
            if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
                if player.position.x >= alienMissile.position.x {
                    //alienMissile.physicsBody?.velocity.dx = CGFloat(60)
                    alienMissile.physicsBody?.applyForce(CGVector(dx: 0.2, dy: 0))
                } else if player.position.x < alienMissile.position.x {
                    //alienMissile.physicsBody?.velocity.dx = CGFloat(-60)
                    alienMissile.physicsBody?.applyForce(CGVector(dx: -0.2, dy: 0))
                }
            }
            if alienMissile.position.y <= (0 - alienMissile.size.height) {
                alienMissileArray.remove(at: alienMissileArray.index(of: alienMissile)!)
                alienMissile.removeFromParent()
            }
        }
    }
    
    
    // FIRST BOSS
    // Sets up the first boss- eyeBoss
    func setUpEyeBoss() {
        stopSpawns()
        warningFlashing(scene: self.scene!)
        spawnEyeBoss()
        eyeBossSpawned = true
    }
    
    // Spawns the first boss- eyeBoss
    func spawnEyeBoss() {
        setupMusic(music: "battle", type: "wav")
        let eyeBoss = SKSpriteNode(imageNamed: "eyeBoss1")
        eyeBoss.userData = NSMutableDictionary()
        eyeBoss.userData?.setValue(false, forKey: "isDead")
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
        setUpSpawnLittleEyes(min: 2, max: 3)
    }
    
    // Sets up the physicsBody of eyeBoss, called after eyeBoss has moved into position
    func setUpEyeBossPhysicsBody(eyeBoss: SKSpriteNode){
        eyeBoss.physicsBody = SKPhysicsBody(texture: eyeBoss.texture!, size: eyeBoss.size)
        eyeBoss.physicsBody?.isDynamic = true
        eyeBoss.physicsBody?.affectedByGravity = false
        eyeBoss.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        eyeBoss.physicsBody?.contactTestBitMask = PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Player | PhysicsCategory.Shield
        eyeBoss.physicsBody?.collisionBitMask = PhysicsCategory.None
        eyeBoss.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func processEyeBossMovement(forUpdate currentTime: CFTimeInterval) {
        if let eyeBoss = childNode(withName: kEyeBossName) as? SKSpriteNode {
            if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
                if player.position.x - 5 >= eyeBoss.position.x {
                    eyeBoss.physicsBody?.velocity.dx = CGFloat(60)
                } else if player.position.x + 5 <= eyeBoss.position.x {
                    eyeBoss.physicsBody?.velocity.dx = CGFloat(-60)
                } else {
                    eyeBoss.physicsBody?.velocity.dx = CGFloat(0)
                }
            }
            if let eyeBossLaser = childNode(withName: kEyeBossLaserName) as? SKSpriteNode {
                eyeBossLaser.position.x = eyeBoss.position.x
            }
            if let eyeBossLaserCharge = childNode(withName: kEyeBossLaserChargeName) as? SKSpriteNode {
                eyeBossLaserCharge.position.x = eyeBoss.position.x
            }
        }
    }
    
    // TODO: Add more eyeBoss attacks-> 3 total because spawns littleEyes
    func processEyeBossAttacks(attackChosen: Int) {
        switch attackChosen {
        case 1:
            eyeBossLaserBeamAttack()
        case 2:
            eyeBossChargeAttack()
        case 3:
            eyeBossMultiLaserAttack()
        default:
            return
        }
    }
    
    func eyeBossLaserBeamAttack() {
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
            
            let eyeBossLaser = SKSpriteNode(imageNamed: "teslaColor1")
            eyeBossLaser.size = CGSize(width: 101, height: self.size.height)
            eyeBossLaser.zPosition = 2
            eyeBossLaser.name = self.kEyeBossLaserName
            
            eyeBossLaser.physicsBody = SKPhysicsBody(rectangleOf: eyeBossLaser.size - CGSize(width: 91, height: 0))
            eyeBossLaser.physicsBody?.isDynamic = false
            eyeBossLaser.physicsBody?.categoryBitMask = PhysicsCategory.EyeBossLaserAttack
            eyeBossLaser.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile | PhysicsCategory.Enemy | PhysicsCategory.Shield
            eyeBossLaser.physicsBody?.collisionBitMask = PhysicsCategory.None
            if let eyeBoss = self.childNode(withName: self.kEyeBossName) as? SKSpriteNode {
                eyeBossLaser.position = eyeBoss.position - CGPoint(x: 0, y: eyeBoss.size.height/2 + (eyeBossLaser.size.height/2))
            }
            chargeLaser.removeFromParent()
            self.addChild(eyeBossLaser)
            
            var gifLaser: [SKTexture] = []
            for i in 1...12 {
                gifLaser.append(SKTexture(imageNamed: "teslaColor\(i)"))
            }
            eyeBossLaser.run(SKAction.repeatForever(SKAction.animate(with: gifLaser, timePerFrame: 0.03)))
            
            eyeBossLaser.run(SKAction.wait(forDuration: 3), completion: {
                eyeBossLaser.removeFromParent()
            })
        })
    }
    
    func eyeBossChargeAttack() {
        if let eyeBoss = childNode(withName: kEyeBossName) as? SKSpriteNode {
            eyeBoss.texture = SKTexture(imageNamed: "eyeBoss2")
            let actionMove = SKAction.move(to: eyeBoss.position - CGPoint(x: 0, y: size.height + eyeBoss.size.height), duration: 1.2)
            
            eyeBoss.run(actionMove, completion: {
                eyeBoss.position = CGPoint(x: eyeBoss.position.x, y: self.size.height + eyeBoss.size.height)
                eyeBoss.texture = SKTexture(imageNamed: "eyeBoss1")
                eyeBoss.run(SKAction.move(to: CGPoint(x: eyeBoss.position.x, y: self.size.height - eyeBoss.size.height), duration: 1.5))
            })
        }
    }
    
    func eyeBossMultiLaserAttack() {
        //TODO: Do this. Shoot a laser from each vein - they all converge on a single point and move outwards
        
    }
    
    // adds little eyeballs only while eyeBoss is active
    func setUpSpawnLittleEyes(min: CGFloat, max: CGFloat) {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addSpawnLittleEyes),
                SKAction.wait(forDuration: Double(random(min: CGFloat(min), max: CGFloat(max))))
                ])
        ))
    }
    
    func addSpawnLittleEyes() {
        let littleEye = SKSpriteNode(imageNamed: "")
        littleEye.name = kLittleEyeName
        littleEye.size = CGSize(width: 32, height: 32)
        littleEye.zPosition = 5
        littleEye.userData = NSMutableDictionary()
        littleEye.userData?.setValue(false, forKey: "isDead")
        setLittleEyeHealth(littleEye: littleEye)
        
        littleEye.physicsBody = SKPhysicsBody(texture: littleEye.texture!, size: littleEye.size - CGSize(width: 12, height: 12))
        littleEye.physicsBody?.isDynamic = true
        littleEye.physicsBody?.affectedByGravity = false
        littleEye.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        littleEye.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.EyeBossLaserAttack | PhysicsCategory.Shield
        littleEye.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let actualX = random(min: littleEye.size.width/2, max: size.width - littleEye.size.width/2)
        littleEye.position = CGPoint(x: actualX, y: size.height + littleEye.size.height/2)
        addChild(littleEye)
        setUpLittleEyeBehaviour(littleEye: littleEye)
    }
    
    // Controls the movement and attacking of the littleEyes. Also calls the littleEyeGif functions to gives the littleEye's animations
    func setUpLittleEyeBehaviour(littleEye: SKSpriteNode) {
        let playBlinkingGif = SKAction.run {
            self.setUpLittleEyeBlinkingGif(littleEye: littleEye)
        }
        let playWaitingGif = SKAction.run {
            self.setUpLittleEyeRestingGif(littleEye: littleEye)
        }
        let wait = SKAction.wait(forDuration: Double(random(min: CGFloat(3), max: CGFloat(5))))
        let randomX = random(min: littleEye.size.width/2, max: size.width - littleEye.size.width/2)
        let randomY = random(min: size.height/3, max: size.height - littleEye.size.height/2)
        let locationToMoveTo = CGPoint(x: randomX, y: randomY)
        let opposite = (locationToMoveTo.y - littleEye.position.y)
        let adjacent = (locationToMoveTo.x - littleEye.position.x)
        let distanceOfLocationToMoveTo = sqrtf(powf(Float(opposite), 2.0) + powf(Float(adjacent), 2.0))
        let angleToRotateTo = angleToRotateToWhileFacingDown(adjacent: adjacent, opposite: opposite)
        let turn1 = SKAction.rotate(toAngle: angleToRotateTo, duration: 0.5)
        let playMovingGif = SKAction.run {
            self.setUpLittleEyeMovingGif(littleEye: littleEye)
        }
        let move = SKAction.move(to: locationToMoveTo, duration: TimeInterval(distanceOfLocationToMoveTo/120))
        let turn2 = SKAction.rotate(toAngle: 0, duration: 0.5)
        let fire = SKAction.run {
            self.littleEyeFireLaser(littleEye: littleEye)
        }
        littleEye.run(SKAction.sequence([SKAction.wait(forDuration: TimeInterval(random(min: 0, max: 10))), playBlinkingGif]))
        littleEye.run(SKAction.sequence([playWaitingGif, wait, turn1, playMovingGif, move, playWaitingGif, turn2, fire]), completion: { () -> Void in
            self.setUpLittleEyeBehaviour(littleEye: littleEye)
        })
    }
    
    // fires a laser towards the player
    func littleEyeFireLaser(littleEye: SKSpriteNode) {
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            let laser = SKSpriteNode(imageNamed: "Bullet_Green_Laser")
            laser.size = CGSize(width: 20, height: 20)
            laser.name = kAlienLaserName
            laser.zPosition = 4
            laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
            laser.physicsBody?.isDynamic = false
            laser.physicsBody?.categoryBitMask = PhysicsCategory.AlienLaser
            laser.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Shield
            laser.physicsBody?.collisionBitMask = PhysicsCategory.None
            laser.physicsBody?.usesPreciseCollisionDetection = true
            
            laser.position = littleEye.position - CGPoint(x: 0, y: littleEye.size.height/2 + laser.size.height/2)
            
            
            let xAndHypotenuse = shootTowardsPlayer(player: player, sprite: littleEye)
            laser.zRotation = faceTowards(sprite1: laser, sprite2: player) + 180 * DegreesToRadians
            let actualDuration = xAndHypotenuse[1] / 245
            let actionMove = SKAction.move(to: CGPoint(x: xAndHypotenuse[0], y: -100), duration: TimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
            laser.run(SKAction.sequence([actionMove, actionMoveDone]))
            addChild(laser)
        }
    }
    
    func setUpLittleEyeRestingGif(littleEye: SKSpriteNode) {
        var gifResting: [SKTexture] = []
        for i in 0...7 {
            gifResting.append(SKTexture(imageNamed: "eyeball spritesheet-0-\(i)"))
        }
        littleEye.run(SKAction.repeat(SKAction.animate(with: gifResting, timePerFrame: 0.1), count: 7))
    }
    
    func setUpLittleEyeMovingGif(littleEye: SKSpriteNode) {
        var gifMoving: [SKTexture] = []
        for i in 0...7 {
            gifMoving.append(SKTexture(imageNamed: "eyeball spritesheet-1-\(i)"))
        }
        littleEye.run(SKAction.repeat(SKAction.animate(with: gifMoving, timePerFrame: 0.1), count: 6))
    }
    
    func setUpLittleEyeBlinkingGif(littleEye: SKSpriteNode) {
        var gifBlinking: [SKTexture] = []
        for i in 0...7 {
            gifBlinking.append(SKTexture(imageNamed: "eyeball spritesheet-2-\(i)"))
        }
        littleEye.run(SKAction.repeat(SKAction.animate(with: gifBlinking, timePerFrame: 0.1), count: 1))
    }
    
    // SECOND BOSS
    func setUpBoss2() {
        stopSpawns()
        warningFlashing(scene: self.scene!)
        spawnBoss2()
        boss2Spawned = true
    }
    
    func spawnBoss2() {
        // TODO: Add music
        setupMusic(music: "action", type: "mp3")
        addHeavyAlien(position: CGPoint(x: size.width/4, y: size.height), initialDelay: 0)
        addHeavyAlien(position: CGPoint(x: size.width * (3/4), y: size.height), initialDelay: 0.3)
        let boss2 = SKSpriteNode(imageNamed: "boss2")
        boss2.userData = NSMutableDictionary()
        boss2.userData?.setValue(false, forKey: "isDead")
        setBoss2Health(boss2: boss2)
        boss2.size = CGSize(width: 110, height: 152)
        boss2.position = CGPoint(x: size.width/2, y: size.height + boss2.size.height)
        boss2.name = kBoss2Name
        boss2.zPosition = 5
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            let lookAtConstraint = SKConstraint.orient(to: player, offset: SKRange(constantValue: CGFloat.pi / 2))
            boss2.constraints = [lookAtConstraint]
        }
        
        
        addChild(boss2)
        boss2.run(SKAction.move(to: CGPoint(x: size.width/2, y: size.height - boss2.size.height/2 - 20), duration: 10.0), completion: { () -> Void in
            self.setUpBoss2PhysicsBody(boss2: boss2)
            self.boss2FullySpawned = true
        })
    }
    
    func setUpBoss2PhysicsBody(boss2: SKSpriteNode){
        boss2.physicsBody = SKPhysicsBody(texture: boss2.texture!, size: boss2.size)
        boss2.physicsBody?.isDynamic = true
        boss2.physicsBody?.affectedByGravity = false
        boss2.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        boss2.physicsBody?.contactTestBitMask = PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Player | PhysicsCategory.Shield
        boss2.physicsBody?.collisionBitMask = PhysicsCategory.None
        boss2.physicsBody?.usesPreciseCollisionDetection = true
        boss2.physicsBody?.velocity.dx = CGFloat(40)
    }
    
    func addHeavyAlien(position: CGPoint, initialDelay: CGFloat) {
        let heavyAlien = SKSpriteNode(imageNamed: "heavyenemy")
        heavyAlien.userData = NSMutableDictionary()
        heavyAlien.userData?.setValue(false, forKey: "isDead")
        setHeavyAlienHealth(heavyAlien: heavyAlien)
        heavyAlien.size = CGSize(width: 80, height: 80)
        heavyAlien.position = position + CGPoint(x: 0, y: heavyAlien.size.height/2)
        heavyAlien.name = kHeavyAlienName
        heavyAlien.zPosition = 4
        
        
        addChild(heavyAlien)
        heavyAlien.run(SKAction.move(to: position - CGPoint(x: 0, y: heavyAlien.size.height + 152), duration: 10.0), completion: { () -> Void in
            self.setUpHeavyAlienPhysicsBody(heavyAlien: heavyAlien)
            self.setUpHeavyAlienBehaviour(heavyAlien: heavyAlien, initialDelay: initialDelay)
        })
    }
    
    func setUpHeavyAlienPhysicsBody(heavyAlien: SKSpriteNode) {
        heavyAlien.physicsBody = SKPhysicsBody(texture: heavyAlien.texture!, size: heavyAlien.size)
        heavyAlien.physicsBody?.isDynamic = true
        heavyAlien.physicsBody?.affectedByGravity = false
        heavyAlien.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        heavyAlien.physicsBody?.contactTestBitMask = PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Player | PhysicsCategory.Shield
        heavyAlien.physicsBody?.collisionBitMask = PhysicsCategory.None
        heavyAlien.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func setUpHeavyAlienBehaviour(heavyAlien: SKSpriteNode, initialDelay: CGFloat) {
        let initialWait = SKAction.wait(forDuration: TimeInterval(initialDelay))
        let wait = SKAction.wait(forDuration: 0.6)
        let fireLeft = SKAction.run {
            self.addAlienCruiserMissile(alienCruiser: heavyAlien, offset: -18)
        }
        let fireRight = SKAction.run {
            self.addAlienCruiserMissile(alienCruiser: heavyAlien, offset: 18)
        }
        heavyAlien.run(SKAction.sequence([initialWait, SKAction.repeatForever(SKAction.sequence([wait, fireLeft, wait, fireRight]))]))
    }
    
    
    // Move boss2 back and forth
    func processBoss2Movement() {
        if let boss2 = childNode(withName: kBoss2Name) as? SKSpriteNode {
            if boss2.position.x >= size.width - boss2.size.width {
                boss2.physicsBody?.velocity.dx = CGFloat(-40)
            } else if boss2.position.x <= 0 + boss2.size.width {
                boss2.physicsBody?.velocity.dx = CGFloat(40)
            }
        }
    }
    
    // shoots a volley of plasma attacks, aggros if both heavyAliens are dead
    func boss2Attack() {
        if let boss2 = childNode(withName: kBoss2Name) as? SKSpriteNode {
            let wait = SKAction.wait(forDuration: 0.2)
            let leftAttack = SKAction.run {
                self.addBoss2PlasmaAttack(position: boss2.position - CGPoint(x: boss2.size.width/6, y: boss2.size.height/2), rotation: boss2.zRotation)
            }
            let rightAttack = SKAction.run {
                self.addBoss2PlasmaAttack(position: boss2.position - CGPoint(x: -boss2.size.width/6, y: boss2.size.height/2), rotation: boss2.zRotation)
            }
            let oneAttack = SKAction.sequence([wait, leftAttack, wait, rightAttack])
            boss2.run(SKAction.repeat(oneAttack, count: 10))
            
            if numberHeavyAlienKilled == 2 {
                let aoeAttack = SKAction.run {
                    self.addBoss2AoeAttack(position: boss2.position)
                }
                let aoeWait = SKAction.wait(forDuration: 0.4)
                boss2.run(SKAction.repeat(SKAction.sequence([aoeAttack, aoeWait]), count: 12))
            }
            
        }
    }
    
    func addBoss2PlasmaAttack(position: CGPoint, rotation: CGFloat) {
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            let plasma = SKSpriteNode(imageNamed: "plasma")
            plasma.name = kPlasmaName
            plasma.zPosition = 4
            plasma.physicsBody = SKPhysicsBody(texture: plasma.texture!, size: plasma.size - CGSize(width: 20, height: 20))
            plasma.physicsBody?.isDynamic = false
            plasma.physicsBody?.categoryBitMask = PhysicsCategory.Plasma
            plasma.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Shield
            plasma.physicsBody?.collisionBitMask = PhysicsCategory.None
            plasma.physicsBody?.usesPreciseCollisionDetection = true
            
            let rotationInDegrees = rotation * RadiansToDegrees
            if rotationInDegrees >= 180 {
                plasma.position = position - CGPoint(x: pow((360 - rotationInDegrees), 1.1), y: 0)
            } else {
                plasma.position = position + CGPoint(x: pow(rotationInDegrees, 1.1), y: 0)
            }
            
            let adjacent = player.position.y - position.y
            let opposite = player.position.x - position.x
            let angle = tan(opposite/adjacent)
            let newAdjacent = adjacent - 100
            let newOpposite = tan(angle) * newAdjacent
            let newHypotenuse = sqrt(pow(newAdjacent, 2.0) + pow(newOpposite, 2.0))
            let newX = position.x + newOpposite
            plasma.zRotation = faceTowards(sprite1: plasma, sprite2: player)
            let actualDuration = newHypotenuse / 245
            let actionMove = SKAction.move(to: CGPoint(x: newX, y: -100), duration: TimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
            plasma.run(SKAction.sequence([actionMove, actionMoveDone]))
            addChild(plasma)
        }
    }
    
    func addBoss2AoeAttack(position: CGPoint) {
        for x in 0 ... 18 {
            addAoeLaser(position: position, rotation: DegreesToRadians * CGFloat(180 + x * 10), image: "Bullet_Orange_Sphere_Glow")
        }
    }
    
    // Called when boss2 is killed
    func setUpBoss2Explosion(boss2: SKNode) {
        var gifExplosion: [SKTexture] = []
        for i in 0...10 {
            gifExplosion.append(SKTexture(imageNamed: "boss2Explosion\(i)"))
        }
        let audioNode1 = SKAudioNode(fileNamed: "boss2explosion")
        audioNode1.autoplayLooped = true
        self.addChild(audioNode1)
        let playAction = SKAction.play()
        audioNode1.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 4.1), SKAction.removeFromParent()]))
        boss2.run(SKAction.repeat(SKAction.animate(with: gifExplosion, timePerFrame: 0.04), count: 10), completion: {
            self.explosionEffect(position: boss2.position, fileName: "MissileExplosionParticle.sks", score: self.boss2killScore, sound: "explosion")
            GameData.shared.playerScore = GameData.shared.playerScore + self.boss2killScore
            boss2.removeFromParent()
        })
    }
    
    
    // THIRD BOSS
    func setUpBoss3() {
        stopSpawns()
        warningFlashing(scene: self.scene!)
        spawnBoss3()
        boss3Spawned = true
    }
    
    func spawnBoss3() {
        setupMusic(music: "boss3", type: "wav")
        let boss3 = SKSpriteNode(imageNamed: "boss3-1")
        boss3.userData = NSMutableDictionary()
        boss3.userData?.setValue(false, forKey: "isDead")
        setBoss3Phase1Health(boss3: boss3)
        boss3.size = CGSize(width: 256, height: 320)
        boss3.position = CGPoint(x: size.width/2, y: size.height + boss3.size.height)
        boss3.name = kBoss3Phase1Name
        boss3.zPosition = 3
        
        addChild(boss3)
        boss3.run(SKAction.move(to: CGPoint(x: size.width/2, y: size.height - boss3.size.height/2), duration: 10.0), completion: { () -> Void in
            self.setUpBoss3PhysicsBody(boss3: boss3)
            self.boss3FullySpawned = true
            self.boss3Phase1 = true
            self.setUpBoss3HarvesterSpawn()
        })
    }
    
    func setUpBoss3PhysicsBody(boss3: SKSpriteNode) {
        boss3.physicsBody = SKPhysicsBody(texture: boss3.texture!, size: boss3.size)
        boss3.physicsBody?.isDynamic = true
        boss3.physicsBody?.affectedByGravity = false
        boss3.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        boss3.physicsBody?.contactTestBitMask = PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Player | PhysicsCategory.Shield
        boss3.physicsBody?.collisionBitMask = PhysicsCategory.None
        boss3.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func setUpBoss3HarvesterSpawn() {
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addBoss3Harvester),
                SKAction.wait(forDuration: Double(random(min: CGFloat(3), max: CGFloat(4))))
                ])
        ))
    }
    
    func addBoss3Harvester() {
        let harvester = SKSpriteNode(imageNamed: "boss3-harvester")
        harvester.name = kHarvesterName
        harvester.size = CGSize(width: 64, height: 64)
        harvester.userData = NSMutableDictionary()
        harvester.userData?.setValue(false, forKey: "isDead")
        setHarvesterHealth(harvester: harvester)
        
        harvester.physicsBody = SKPhysicsBody(texture: harvester.texture!, size: harvester.size)
        harvester.physicsBody?.isDynamic = false
        harvester.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        harvester.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Shield
        harvester.physicsBody?.collisionBitMask = PhysicsCategory.None
        harvester.zPosition = 1
        if let boss3 = childNode(withName: kBoss3Phase1Name) as? SKSpriteNode {
            harvester.position = boss3.position - CGPoint(x: 0, y: boss3.size.height/4)
        }
        addChild(harvester)
        harvester.run(SKAction.move(to: harvester.position - CGPoint(x: 0, y: 100), duration: 1.0), completion: { () -> Void in self.setUpHarvesterBehaviour(harvester: harvester)})
    }
    
    func setUpHarvesterBehaviour(harvester: SKSpriteNode){
        let wait1 = SKAction.wait(forDuration: Double(random(min: CGFloat(0.5), max: CGFloat(2))))
        let wait2 = SKAction.wait(forDuration: Double(random(min: CGFloat(0.5), max: CGFloat(2))))
        let randomX = random(min: harvester.size.width/2, max: size.width - harvester.size.width/2)
        let randomY = random(min: size.height/5, max: size.height * (5/8))
        let locationToMoveTo = CGPoint(x: randomX, y: randomY)
        let opposite = (locationToMoveTo.y - harvester.position.y)
        let adjacent = (locationToMoveTo.x - harvester.position.x)
        let distanceOfLocationToMoveTo = sqrtf(powf(Float(opposite), 2.0) + powf(Float(adjacent), 2.0))
        let angleToRotateTo = angleToRotateToWhileFacingDown(adjacent: adjacent, opposite: opposite)
        let turn1 = SKAction.rotate(toAngle: angleToRotateTo, duration: 0.5)
        let move = SKAction.move(to: locationToMoveTo, duration: TimeInterval(distanceOfLocationToMoveTo/220))
        let turn2 = SKAction.rotate(toAngle: 0, duration: 0.5)
        let fire = SKAction.run {
            self.addHarvesterAttack(harvester: harvester)
        }
        harvester.run(SKAction.sequence([turn1, move, turn2, wait1, fire, wait2]), completion: { () -> Void in
            self.setUpHarvesterBehaviour(harvester: harvester)
        })
    }
    
    func addHarvesterAttack(harvester: SKSpriteNode) {
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            let bloodProjectile = SKSpriteNode(imageNamed: "evilProjectile1")
            bloodProjectile.size = CGSize(width: 33.5, height: 33.5)
            bloodProjectile.name = kBloodProjectileName
            bloodProjectile.zPosition = 4
            bloodProjectile.physicsBody = SKPhysicsBody(texture: bloodProjectile.texture!, size: bloodProjectile.size)
            bloodProjectile.physicsBody?.isDynamic = false
            bloodProjectile.physicsBody?.categoryBitMask = PhysicsCategory.BloodProjectile
            bloodProjectile.physicsBody?.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Shield
            bloodProjectile.physicsBody?.collisionBitMask = PhysicsCategory.None
            bloodProjectile.physicsBody?.usesPreciseCollisionDetection = true
            
            bloodProjectile.position = harvester.position - CGPoint(x: 0, y: harvester.size.height/2)
            
            let xAndHypotenuse = shootTowardsPlayer(player: player, sprite: harvester)
            bloodProjectile.zRotation = faceTowards(sprite1: bloodProjectile, sprite2: player)
            let actualDuration = xAndHypotenuse[1] / 245
            let actionMove = SKAction.move(to: CGPoint(x: xAndHypotenuse[0], y: -100), duration: TimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
            bloodProjectile.run(SKAction.sequence([actionMove, actionMoveDone]))
            addChild(bloodProjectile)
            
            
            var gifBlood: [SKTexture] = []
            for i in 1...7 {
                gifBlood.append(SKTexture(imageNamed: "evilProjectile\(i)"))
            }
            bloodProjectile.run(SKAction.repeatForever(SKAction.animate(with: gifBlood, timePerFrame: 0.1)))
        }
    }
    
    func spawnBoss3Phase2 () {
        let boss3 = SKSpriteNode(imageNamed: "boss3-2")
        boss3.userData = NSMutableDictionary()
        boss3.userData?.setValue(false, forKey: "isDead")
        setBoss3Phase2Health(boss3: boss3)
        boss3.size = CGSize(width: 256, height: 320)
        boss3.position = CGPoint(x: size.width/2, y: size.height - boss3.size.height/2)
        boss3.name = kBoss3Phase2Name
        boss3.zPosition = 3
        self.boss3Phase2 = true
        
        boss3.physicsBody = SKPhysicsBody(texture: boss3.texture!, size: boss3.size)
        boss3.physicsBody?.isDynamic = true
        boss3.physicsBody?.affectedByGravity = false
        boss3.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        boss3.physicsBody?.contactTestBitMask = PhysicsCategory.PlayerProjectile | PhysicsCategory.MissileExplosion | PhysicsCategory.Player | PhysicsCategory.Shield
        boss3.physicsBody?.collisionBitMask = PhysicsCategory.None
        boss3.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(boss3)
    }
    
    func processBoss3Phase2Movement() {
        
    }
    
    func processBoss3Phase2Attacks(attackChosen: Int) {
        switch attackChosen {
        case 1:
            boss3ReverseControls()
        case 2:
            boss3Attack2()
        case 3:
            boss3Attack3()
        default:
            return
        }
    }
    
    func boss3ReverseControls() {
        if let boss3 = childNode(withName: kBoss3Phase2Name) as? SKSpriteNode {
            let audioNode = SKAudioNode(fileNamed: "laserchargesound")
            audioNode.autoplayLooped = false
            self.addChild(audioNode)
            let playAction = SKAction.play()
            audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
            
            let glow = SKAction.run {
                boss3.addGlow()
            }
            let wait = SKAction.wait(forDuration: 2.0)
            let endGlow = SKAction.run {
                boss3.removeGlow()
                self.playerMovingDirection = -self.playerMovingDirection
            }
            boss3.run(SKAction.sequence([glow, wait, endGlow]))
        }
    }
    
    func boss3Attack2() {
        if let boss3 = childNode(withName: kBoss3Phase2Name) as? SKSpriteNode {
            let waitWithinVolley = SKAction.wait(forDuration: 0.2)
            let attackVolleyAttack = SKAction.run {
                // TODO: Play shooting sound- shotgun type sound?
                for _ in 0 ... 20 {
                    self.addAoeLaser(position: boss3.position - CGPoint(x: 0, y: boss3.size.height/2), rotation: DegreesToRadians * random(min: 180, max: 360), image: "Bullet_Orange_Sphere")
                }
                
            }
            let attackVolley = SKAction.sequence([attackVolleyAttack, waitWithinVolley, attackVolleyAttack, waitWithinVolley, attackVolleyAttack])
            let wait = SKAction.wait(forDuration: 1)
            boss3.run(SKAction.sequence([attackVolley, wait, attackVolley, wait, attackVolley, wait, attackVolley, wait, attackVolley, wait]))
        }
        
    }
    
    func boss3Attack3() {
        if let boss3 = childNode(withName: kBoss3Phase2Name) as? SKSpriteNode {
            let wait = SKAction.wait(forDuration: 0.1)
            let fireLeft = SKAction.run {
                self.addAlienCruiserMissile(alienCruiser: boss3, offset: -30)
            }
            let fireRight = SKAction.run {
                self.addAlienCruiserMissile(alienCruiser: boss3, offset: 30)
            }
            boss3.run(SKAction.repeat(SKAction.sequence([wait, fireLeft, wait, fireRight]), count: 20))
        }
    }
    
    // POWERUPS
    func addPowerUp(position: CGPoint, image: String, name: String) {
        let powerUp = SKSpriteNode(imageNamed: image)
        powerUp.name = name
        powerUp.size = CGSize(width: 20, height: 20)
        powerUp.physicsBody = SKPhysicsBody(rectangleOf: powerUp.size)
        powerUp.physicsBody?.isDynamic = true
        powerUp.physicsBody?.affectedByGravity = true
        powerUp.physicsBody?.categoryBitMask = PhysicsCategory.UpgradePack
        powerUp.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        powerUp.physicsBody?.collisionBitMask = PhysicsCategory.None
        powerUp.physicsBody?.usesPreciseCollisionDetection = true
        
        
        //let actualDuration = random(min: CGFloat(20.0), max: CGFloat(24.0))
        powerUp.position = position
        //let actionMove = SKAction.move(to: CGPoint(x: powerUp.position.x, y: position.y - 2000), duration: TimeInterval(actualDuration))
        let actionWait = SKAction.wait(forDuration: 10)
        let actionMoveDone = SKAction.removeFromParent()
        powerUp.run(SKAction.sequence([actionWait, actionMoveDone]))
        addChild(powerUp)
        //powerUp.physicsBody?.applyForce(CGVector(dx: 0, dy: 8.0))
        powerUp.physicsBody?.velocity = CGVector(dx: random(min: -25, max: 25), dy: 200)
        
    }
    
    // Spawns a random powerup- different power ups for laser and for missile, weighted drop rate
    func spawnRandomPowerUp(position: CGPoint, percentChance: CGFloat) {
        if playerWeapon == kLaserName {
            spawnHealthRandom(position: position, percentChance: percentChance/4)
            spawnProtectiveShieldRandom(position: position, percentChance: percentChance/3)
            if fireRateUpgradeNumber < 7 {
                spawnFireRateRandom(position: position, percentChance: percentChance/6)
            }
            if !fiveShotUpgrade {
                spawnThreeShotRandom(position: position, percentChance: percentChance/5)
            }
            if numberOfHomingMissileUpgrades <= 5 {
                spawnHomingMissileRandom(position: position, percentChance: percentChance/10)
            }
            if laserDamageUpgradeNumber <= 5 {
                spawnLaserDamageRandom(position: position, percentChance: percentChance/5)
            }
        }
        if playerWeapon == kMissileName {
            spawnHealthRandom(position: position, percentChance: percentChance/4)
            spawnProtectiveShieldRandom(position: position, percentChance: percentChance/3)
            if fireRateUpgradeNumber < 7 {
                spawnFireRateRandom(position: position, percentChance: percentChance/4)
            }
            if numberOfHomingMissileUpgrades <= 5 {
                spawnHomingMissileRandom(position: position, percentChance: percentChance/4)
            }
            if missileExplosionDamageUpgradeNumber <= 5 {
                spawnMissileExplosionDamageRandom(position: position, percentChance: percentChance/4)
            }
            if largerExplosionUpgradeNumber <= 5 {
                spawnLargerExplosionRandom(position: position, percentChance: percentChance/3)
            }
        }
    }
    
    func spawnHealthRandom(position: CGPoint, percentChance: CGFloat) {
        let randomNum = random(min: CGFloat(0.0), max: CGFloat(100.0))
        if(randomNum <= percentChance){
            addPowerUp(position: position, image: "healthpack", name: kHealthPackName)
        }
    }
    
    func spawnFireRateRandom(position: CGPoint, percentChance: CGFloat) {
        let randomNum = random(min: CGFloat(0.0), max: CGFloat(100.0))
        if(randomNum <= percentChance){
            addPowerUp(position: position, image: "firerateupgrade", name: kFireRateUpgradeName)
        }
    }
    
    func spawnThreeShotRandom(position: CGPoint, percentChance: CGFloat) {
        let randomNum = random(min: CGFloat(0.0), max: CGFloat(100.0))
        if(randomNum <= percentChance){
            addPowerUp(position: position, image: "threeshotupgrade", name: kThreeShotUpgradeName)
        }
    }
    
    func spawnProtectiveShieldRandom(position: CGPoint, percentChance: CGFloat) {
        let randomNum = random(min: CGFloat(0.0), max: CGFloat(100.0))
        if(randomNum <= percentChance){
            addPowerUp(position: position, image: "protectiveShield", name: kProtectiveShieldUpgradeName)
        }
    }
    
    func spawnHomingMissileRandom(position: CGPoint, percentChance: CGFloat) {
        let randomNum = random(min: CGFloat(0.0), max: CGFloat(100.0))
        if(randomNum <= percentChance){
            addPowerUp(position: position, image: "homingMissileUpgrade", name: kHomingMissileUpgradeName)
        }
    }
    
    func spawnLaserDamageRandom(position: CGPoint, percentChance: CGFloat) {
        let randomNum = random(min: CGFloat(0.0), max: CGFloat(100.0))
        if(randomNum <= percentChance){
            addPowerUp(position: position, image: "Powerup_Red_Glow", name: kLaserDamageUpgradeName)
        }
    }
    
    func spawnMissileExplosionDamageRandom(position: CGPoint, percentChance: CGFloat) {
        let randomNum = random(min: CGFloat(0.0), max: CGFloat(100.0))
        if(randomNum <= percentChance){
            addPowerUp(position: position, image: "Powerup_Red_Glow", name: kMissileExplosionDamageUpgradeName)
        }
    }
    
    func spawnLargerExplosionRandom(position: CGPoint, percentChance: CGFloat) {
        let randomNum = random(min: CGFloat(0.0), max: CGFloat(100.0))
        if(randomNum <= percentChance){
            addPowerUp(position: position, image: "Powerup_Yellow_Glow", name: kMissileExplosionSizeUpgradeName)
        }
    }
    
    
    func addProtectiveShield() {
        protectiveShieldActive = true
        let shield = SKSpriteNode(imageNamed: "shield")
        shield.name = kProtectiveShieldName
        shield.size = CGSize(width: 40, height: 40)
        shield.zPosition = 5
        shield.userData = NSMutableDictionary()
        shield.userData?.setValue(false, forKey: "isDead")
        setShieldHealth(shield: shield)
        
        shield.physicsBody = SKPhysicsBody(texture: shield.texture!, size: shield.size)
        shield.physicsBody?.isDynamic = true
        shield.physicsBody?.affectedByGravity = false
        shield.physicsBody?.categoryBitMask = PhysicsCategory.Shield
        shield.physicsBody?.contactTestBitMask = PhysicsCategory.AlienLaser | PhysicsCategory.EyeBossLaserAttack | PhysicsCategory.AlienMissile | PhysicsCategory.Enemy
        shield.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            //shield.position = player.position
            shield.constraints = [SKConstraint.distance(SKRange(upperLimit: 0), to: player)]
        }
        addChild(shield)
        
        let actionWait = SKAction.wait(forDuration: GameData.shared.shieldTime)
        let actionWaitDone = SKAction.removeFromParent()
        let actionBool = SKAction.run {
            self.protectiveShieldActive = false
        }
        shield.run(SKAction.sequence([actionWait, actionWaitDone, actionBool]))
    }
    
    func updateProtectiveShield() {
        if let shield = childNode(withName: kProtectiveShieldName) as? SKSpriteNode {
            setShieldHealth(shield: shield)
            shield.removeAllActions()
            let actionWait = SKAction.wait(forDuration: GameData.shared.shieldTime)
            let actionWaitDone = SKAction.removeFromParent()
            let actionBool = SKAction.run {
                self.protectiveShieldActive = false
            }
            shield.run(SKAction.sequence([actionWait, actionWaitDone, actionBool]))
        }
    }
    
    func playPowerUpSound() {
        let audioNode = SKAudioNode(fileNamed: "Free-Power-Ups-Items-098")
        audioNode.autoplayLooped = false
        self.addChild(audioNode)
        let playAction = SKAction.play()
        audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
    }
    
    
    
    
    // Player Weapons
    func firePlayerWeapon(){
        if(playerWeapon == kLaserName){
            let audioNode = SKAudioNode(fileNamed: "Free-Guns-Lasers-035")
            audioNode.autoplayLooped = false
            self.addChild(audioNode)
            let playAction = SKAction.play()
            audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 1), SKAction.removeFromParent()]))
            if fiveShotUpgrade {
                firePlayerLaser(offset: 0)
                firePlayerLaser(offset: -8.0)
                firePlayerLaser(offset: 8.0)
                firePlayerLaser(offset: -16.0)
                firePlayerLaser(offset: 16.0)
            } else if fourShotUpgrade {
                firePlayerLaser(offset: -4.0)
                firePlayerLaser(offset: 4.0)
                firePlayerLaser(offset: -12.0)
                firePlayerLaser(offset: 12.0)
            } else if threeShotUpgrade {
                firePlayerLaser(offset: 0)
                firePlayerLaser(offset: -8.0)
                firePlayerLaser(offset: 8.0)
            } else if twoShotUpgrade {
                firePlayerLaser(offset: -4.0)
                firePlayerLaser(offset: 4.0)
            } else {
                firePlayerLaser(offset: 0)
            }
        }
        if(playerWeapon == kMissileName){
            firePlayerMissile()
        }
    }
    
    func firePlayerLaser(offset: CGFloat) {
        let laser = SKSpriteNode()
        if laserDamageUpgradeNumber >= 5 {
            laser.texture = SKTexture(imageNamed: "playerLaserRed")
        } else if laserDamageUpgradeNumber == 4 {
            laser.texture = SKTexture(imageNamed: "playerLaserOrange")
        } else if laserDamageUpgradeNumber == 3 {
            laser.texture = SKTexture(imageNamed: "playerLaserPink")
        } else if laserDamageUpgradeNumber == 2 {
            laser.texture = SKTexture(imageNamed: "playerLaserYellow")
        } else if laserDamageUpgradeNumber == 1 {
            laser.texture = SKTexture(imageNamed: "playerLaserBlue")
        } else {
            laser.texture = SKTexture(imageNamed: "playerLaserCyan")
        }
        
        laser.size = CGSize(width: 15, height: 15)
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            laser.position = player.position + CGPoint(x: offset, y: player.size.height/2 + laser.size.height/2)
        }
        laser.name = kLaserName
        laser.zPosition = 3
        laser.physicsBody = SKPhysicsBody(rectangleOf: laser.size)
        laser.physicsBody?.isDynamic = true
        laser.physicsBody?.categoryBitMask = PhysicsCategory.PlayerProjectile
        laser.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
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
        missile.size = CGSize(width: 20, height: 30)
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            missile.position = player.position + CGPoint(x: 0, y: player.size.height/2 + missile.size.height/2)
        }
        missile.name = kMissileName
        missile.zPosition = 5
        missile.physicsBody = SKPhysicsBody(rectangleOf: missile.size)
        missile.physicsBody?.isDynamic = true
        missile.physicsBody?.categoryBitMask = PhysicsCategory.PlayerProjectile
        missile.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        missile.physicsBody?.collisionBitMask = PhysicsCategory.None
        missile.physicsBody?.usesPreciseCollisionDetection = true
        missile.physicsBody?.allowsRotation = false
        
        addChild(missile)
        let actionMove = SKAction.move(to: missile.position + CGPoint(x: 0, y: 3000), duration: 7.5)
        let actionMoveDone = SKAction.removeFromParent()
        missile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func missileExplosion(missile: SKNode) {
        let audioNode = SKAudioNode(fileNamed: "Free-Explosions-046")
        audioNode.autoplayLooped = false
        self.addChild(audioNode)
        let playAction = SKAction.play()
        audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
        let missileExplosion = SKSpriteNode()
        missileExplosion.alpha = 0.0
        missileExplosion.size = CGSize(width: 70 * (1 + 0.2 * largerExplosionUpgradeNumber), height: 70 * (1 + 0.2 * largerExplosionUpgradeNumber))
        missileExplosion.position = missile.position
        missileExplosion.userData = NSMutableDictionary()

        missileExplosion.name = kMissileExplosionName
        missileExplosion.physicsBody = SKPhysicsBody(rectangleOf: missileExplosion.size)
        missileExplosion.physicsBody?.isDynamic = true
        missileExplosion.physicsBody?.categoryBitMask = PhysicsCategory.MissileExplosion
        missileExplosion.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        missileExplosion.physicsBody?.collisionBitMask = PhysicsCategory.None
        missile.physicsBody?.usesPreciseCollisionDetection = true
        missileExplosion.physicsBody?.allowsRotation = false

        addChild(missileExplosion)
        missileExplosion.run(SKAction.wait(forDuration: 0.0005), completion: { missileExplosion.removeFromParent() })
    }
    
    func missileExplosionEffect(position: CGPoint) {
        let missileExplosionEffect = SKEmitterNode(fileNamed: "MissileExplosionParticle.sks")
        missileExplosionEffect?.particleBirthRate = CGFloat(1000 + 200 * largerExplosionUpgradeNumber)
        missileExplosionEffect?.particleSpeed = CGFloat(100 * largerExplosionUpgradeNumber)
        missileExplosionEffect?.particlePosition = position
        missileExplosionEffect?.zPosition = 2
        addChild(missileExplosionEffect!)
        missileExplosionEffect?.run(SKAction.wait(forDuration: 2), completion: { missileExplosionEffect?.removeFromParent() })
    }
    
    
    func setUpHomingMissile() {
        let wait = SKAction.wait(forDuration: 5.0/Double(numberOfHomingMissileUpgrades))
        let audioNode = SKAudioNode(fileNamed: "missile")
        audioNode.autoplayLooped = false
        self.addChild(audioNode)
        let playAction = SKAction.play()
        let playSound = SKAction.run {
            audioNode.run(playAction)
        }
        let stopSound = SKAction.run {
            audioNode.run(SKAction.stop())
        }
        let fire = SKAction.run {
            self.addHomingMissile(direction: "Left")
            self.addHomingMissile(direction: "Right")
        }
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            player.run(SKAction.repeatForever(SKAction.sequence([wait, stopSound, fire, playSound])), withKey: "missile")
        }
    }
    
    func addHomingMissile(direction: String) {
        let missile = SKSpriteNode(imageNamed: "homingMissile")
        missile.size = CGSize(width: 7, height: 20)
        missile.name = kHomingMissileName
        missile.zPosition = 5
        missile.userData = NSMutableDictionary()
        missile.physicsBody = SKPhysicsBody(rectangleOf: missile.size)
        missile.physicsBody?.isDynamic = true
        missile.physicsBody?.affectedByGravity = false
        missile.physicsBody?.categoryBitMask = PhysicsCategory.PlayerProjectile
        missile.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        missile.physicsBody?.collisionBitMask = PhysicsCategory.None
        missile.physicsBody?.usesPreciseCollisionDetection = true
        missile.physicsBody?.allowsRotation = false
        
        addChild(missile)
        
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
            if direction == "Left" {
                missile.physicsBody?.velocity.dx = -10
                missile.position = player.position + CGPoint(x: -20, y: 0)
            } else if direction == "Right" {
                missile.physicsBody?.velocity.dx = 10
                missile.position = player.position + CGPoint(x: 20, y: 0)
            }
        }
        setClosestNode(node: missile)
        missile.physicsBody?.velocity.dy = 5
        homingMissileArray.append(missile)
        let wait = SKAction.wait(forDuration:15.0)
        let action = SKAction.removeFromParent()
        missile.run(SKAction.sequence([wait,action]))
    }
    
    // Might have a runtime of... something like O(n^3) if I constantly find what is the closest enemy node and change force applied towards that node at every update for every homing missile.
    // Finds the closest enemy node when the missile is created, constantly moves towards that node.
    // If node it is tracking is destroyed, find a new node to track
    func processHomingMissileMovement() {
        for homingMissile in homingMissileArray {
            if let closestEnemy: SKSpriteNode = homingMissile.userData?.value(forKey: "closest") as? SKSpriteNode {
                if closestEnemy.isHidden == true {
                    setClosestNode(node: homingMissile)
                }
                if homingMissile.position.x > closestEnemy.position.x {
                    homingMissile.physicsBody?.applyForce(CGVector(dx: -1, dy: 0))
                } else {
                    homingMissile.physicsBody?.applyForce(CGVector(dx: 1, dy: 0))
                }
                if homingMissile.position.y > closestEnemy.position.y {
                    homingMissile.physicsBody?.applyForce(CGVector(dx: 0, dy: -1))
                } else {
                    homingMissile.physicsBody?.applyForce(CGVector(dx: 0, dy: 1))
                }
                let positionToRotateTo = atan2((homingMissile.physicsBody?.velocity.dy)!, (homingMissile.physicsBody?.velocity.dx)!)
                homingMissile.zRotation = CGFloat(positionToRotateTo) - 90 * DegreesToRadians
            } else {
                setClosestNode(node: homingMissile)
            }
        }
    }
    
    func setClosestNode(node: SKSpriteNode) {
        var closestNode: CGFloat = 0
        for child in children {
            if child.name != nil && allPossibleEnemies.contains(child.name!) {
                let tempDistance = calculateDistanceBetween(node1: node, node2: child as! SKSpriteNode)
                if tempDistance > closestNode {
                    closestNode = tempDistance
                    node.userData?.setValue(child, forKey: "closest")
                }
            }
        }
    }
    
    func calculateDistanceBetween(node1: SKSpriteNode, node2: SKSpriteNode) -> CGFloat {
        let adjacent = node1.position.y - node2.position.y
        let opposite = node1.position.x - node2.position.x
        return sqrt(pow(adjacent, 2.0) + pow(opposite, 2.0))
    }
    
    func shootTowardsPlayer(player: SKSpriteNode, sprite: SKSpriteNode) -> [CGFloat] {
        let adjacent = player.position.y + player.size.height - (sprite.position.y - sprite.size.height/2)
        let opposite = player.position.x - sprite.position.x
        let angle = atan(opposite/adjacent)
        let newAdjacent = adjacent - 100
        let newOpposite = tan(angle) * newAdjacent
        let newHypotenuse = sqrt(pow(newAdjacent, 2.0) + pow(newOpposite, 2.0))
        let newX = sprite.position.x + newOpposite
        return [newX, newHypotenuse]
    }
    
    // Enemy death effects
    func explosionEffect(position: CGPoint, fileName: String, score: Int, sound: String) {
        if sound != "" {
            let audioNode = SKAudioNode(fileNamed: sound)
            audioNode.autoplayLooped = false
            self.addChild(audioNode)
            let playAction = SKAction.play()
            audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
        }
        let explosionEffect = SKEmitterNode(fileNamed: fileName)
        explosionEffect?.particlePosition = position
        addChild(explosionEffect!)
        explosionEffect?.run(SKAction.wait(forDuration: 1), completion: { explosionEffect?.removeFromParent() })
        if score != 0 {
            let scoreEffect = SKLabelNode(fontNamed: "Avenir")
            scoreEffect.fontSize = 20
            scoreEffect.fontColor = SKColor.white
            scoreEffect.text = "+\(score)"
            scoreEffect.position = position
            scoreEffect.zPosition = 5
            addChild(scoreEffect)
            scoreEffect.run(SKAction.wait(forDuration: 1), completion: { scoreEffect.removeFromParent() })
        }
    }
    
    
    func stopSpawns() {
        removeAllActions()
    }
    
    
    func playerTakesDamage(damage: Int, view: UIView) {
        if playerTempInvulnerable {
            return
        }
        GameData.shared.playerHealth = GameData.shared.playerHealth - damage
        playerTempInvulnerable = true
        let audioNode = SKAudioNode(fileNamed: "playerHit")
        audioNode.autoplayLooped = false
        self.addChild(audioNode)
        let playAction = SKAction.play()
        audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
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
    
    
    // Removes health equal to damage from sprite
    func subtractHealth(sprite: SKNode, damage: CGFloat) {
        let currentHealth: CGFloat = sprite.userData?.value(forKey: "health") as! CGFloat
        let newHealth = currentHealth - damage
        sprite.userData?.setValue(newHealth, forKey: "health")
        if (newHealth <= 0) {
            enemyDead(sprite: sprite)
        }
    }
    
    // Handles when an emeny has less than 0 health (Hint: it dies)
    func enemyDead(sprite: SKNode){
        sprite.isHidden = true
        if (sprite.userData?.value(forKey: "isDead") as? Bool)! {
            return
        }
        sprite.userData?.setValue(true, forKey: "isDead")
        if(sprite.name == kProtectiveShieldName) {
            let audioNode = SKAudioNode(fileNamed: "Free-Power-Ups-Items-078")
            audioNode.autoplayLooped = false
            self.addChild(audioNode)
            let playAction = SKAction.play()
            audioNode.run(SKAction.sequence([playAction, SKAction.wait(forDuration: 2), SKAction.removeFromParent()]))
            protectiveShieldActive = false
            sprite.removeFromParent()
        }
        
        if(sprite.name == kAlienName){
            explosionEffect(position: sprite.position, fileName: "AlienExplosionParticle.sks", score: alienKillScore, sound: "Free-Explosions-081")
            GameData.shared.playerScore = GameData.shared.playerScore + alienKillScore
            spawnRandomPowerUp(position: sprite.position, percentChance: 2.0)
            sprite.removeFromParent()
        }
        if(sprite.name == kMassiveAsteroidName){
            explosionEffect(position: sprite.position, fileName: "AsteroidExplosionParticle.sks", score: massiveAsteroidKillScore, sound: "Free-Explosions-023")
            GameData.shared.playerScore = GameData.shared.playerScore + massiveAsteroidKillScore
            spawnRandomPowerUp(position: sprite.position, percentChance: 45.0)
            
            for _ in 0 ... 11 {
                let randomXOffset = random(min: -120, max: 120)
                let randomYOffset = random(min: -120, max: 120)
                self.addLargeAsteroid(position: sprite.position, xoffset: randomXOffset, yoffset: randomYOffset)
            }
            sprite.removeFromParent()
        }
        if(sprite.name == kLargeAsteroidName){
            explosionEffect(position: sprite.position, fileName: "AsteroidExplosionParticle.sks", score: largeAsteroidKillScore, sound: "Free-Explosions-023")
            GameData.shared.playerScore = GameData.shared.playerScore + largeAsteroidKillScore
            spawnRandomPowerUp(position: sprite.position, percentChance: 4.0)
            self.addMediumAsteroid(position: sprite.position, xoffset: -10)
            self.addMediumAsteroid(position: sprite.position, xoffset: 10)
            sprite.removeFromParent()
        }
        if(sprite.name == kMediumAsteroidName){
            explosionEffect(position: sprite.position, fileName: "AsteroidExplosionMediumParticle.sks", score: mediumAsteroidKillScore, sound: "Free-Explosions-023")
            GameData.shared.playerScore = GameData.shared.playerScore + mediumAsteroidKillScore
            spawnRandomPowerUp(position: sprite.position, percentChance: 2.0)
            self.addSmallAsteroid(position: sprite.position, xoffset: -5)
            self.addSmallAsteroid(position: sprite.position, xoffset: 5)
            sprite.removeFromParent()
        }
        if(sprite.name == kSmallAsteroidName){
            explosionEffect(position: sprite.position, fileName: "AsteroidExplosionSmallParticle.sks", score: smallAsteroidKillScore, sound: "Free-Explosions-023")
            GameData.shared.playerScore = GameData.shared.playerScore + smallAsteroidKillScore
            spawnRandomPowerUp(position: sprite.position, percentChance: 1.0)
            sprite.removeFromParent()
        }
        if(sprite.name == kAlienCruiserName){
            explosionEffect(position: sprite.position, fileName: "MissileExplosionParticle.sks", score: alienCruiserKillScore, sound: "Free-Explosions-096")
            GameData.shared.playerScore = GameData.shared.playerScore + alienCruiserKillScore
            spawnRandomPowerUp(position: sprite.position, percentChance: 10.0)
            sprite.removeFromParent()
        }
        if(sprite.name == kEyeBossName){
            if let laserBeam = childNode(withName: kEyeBossLaserName) {
                laserBeam.removeFromParent()
            }
            if let laserCharge = childNode(withName: kEyeBossLaserChargeName) {
                laserCharge.removeFromParent()
            }
            explosionEffect(position: sprite.position, fileName: "EyeBossExplosionParticle.sks", score: eyeBossKillScore, sound: "pop")
            GameData.shared.playerScore = GameData.shared.playerScore + eyeBossKillScore
            eyeBossFullySpawned = false
            alienTriShotActive = true
            self.timeEyeBossDefeated = timeCounter
            eyeBossDefeated = true
            print("EyeBoss defeated at: \(self.timeEyeBossDefeated)")
            spawnRandomPowerUp(position: sprite.position, percentChance: 150.0)
            // Stop littleEye spawns
            stopSpawns()
            let wait = SKAction.wait(forDuration:2.5)
            let action = SKAction.run {
                self.setupMusic(music: "gameMusic2", type: "wav")
                self.setUpAliens(min: 0.2, max: 0.6)
                self.setUpAsteroids(min: 4, max: 10)
                self.setUpMassiveAsteroids(min: 30, max: 65)
            }
            run(SKAction.sequence([wait,action]))
            sprite.removeFromParent()
        }
        if(sprite.name == kLittleEyeName){
            explosionEffect(position: sprite.position, fileName: "LittleEyeExplosionParticle.sks", score: littleEyeKillScore, sound: "littleEyePop")
            GameData.shared.playerScore = GameData.shared.playerScore + littleEyeKillScore
            spawnRandomPowerUp(position: sprite.position, percentChance: 1.0)
            sprite.removeFromParent()
        }
        if(sprite.name == kBoss2Name){
            boss2FullySpawned = false
            self.timeBoss2Defeated = timeCounter
            boss2Defeated = true
            print("Boss2 defeated at: \(self.timeBoss2Defeated)")
            let tempSprite = SKSpriteNode()
            tempSprite.size = CGSize(width: 110, height: 152)
            tempSprite.position = sprite.position
            tempSprite.zPosition = 3
            addChild(tempSprite)
            sprite.removeFromParent()
            spawnRandomPowerUp(position: tempSprite.position, percentChance: 200.0)
            setUpBoss2Explosion(boss2: tempSprite)
            let wait = SKAction.wait(forDuration:7.0)
            let action = SKAction.run {
                // Increase spawn and change spawns
                self.setupMusic(music: "DOS-88 - City Stomper", type: "mp3")
                self.setUpAliens(min: 0.1, max: 0.4)
                self.setUpAsteroids(min: 4, max: 10)
                self.setUpMassiveAsteroids(min: 28, max: 38)
                self.setUpAlienCruisers(min: 5, max: 10)
            }
            run(SKAction.sequence([wait,action]))
        }
        if(sprite.name == kHeavyAlienName){
            explosionEffect(position: sprite.position, fileName: "MissileExplosionParticle", score: heavyAlienKillScore, sound: "Free-Explosions-042")
            GameData.shared.playerScore = GameData.shared.playerScore + heavyAlienKillScore
            spawnRandomPowerUp(position: sprite.position, percentChance: 50.0)
            sprite.removeFromParent()
            numberHeavyAlienKilled = numberHeavyAlienKilled + 1
        }
        if(sprite.name == kBoss3Phase1Name){
            stopSpawns()
            //TODO: Boss3Phase1 explosion and sound
            let wait = SKAction.wait(forDuration:2.5)
            let action = SKAction.run {
                self.spawnBoss3Phase2()
            }
            run(SKAction.sequence([wait,action]))
            sprite.removeFromParent()
        }
        if (sprite.name == kHarvesterName) {
            explosionEffect(position: sprite.position, fileName: "AlienExplosionParticle.sks", score: harvesterKillScore, sound: "Free-Explosions-093")
            GameData.shared.playerScore = GameData.shared.playerScore + harvesterKillScore
            spawnRandomPowerUp(position: sprite.position, percentChance: 1.0)
            sprite.removeFromParent()
        }
        
        if(sprite.name == kBoss3Phase2Name){
            // TODO: Boss3Phase2 explosion and sound
            GameData.shared.playerScore = GameData.shared.playerScore + boss3KillScore
            boss3FullySpawned = false
            self.timeBoss3Defeated = timeCounter
            boss3Defeated = true
            print("Boss3 defeated at: \(self.timeBoss3Defeated)")
            playerMovingDirection = 1
            //spawnRandomPowerUp(position: sprite.position, percentChance: 400.0)
            let wait = SKAction.wait(forDuration:2.5)
            let action = SKAction.run {
                winSceneLoad(view: self.view!)
            }
            run(SKAction.sequence([wait,action]))
            sprite.removeFromParent()
        }
    }

    
    func processUserMotion() {
        if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
//            if let shield = childNode(withName: kProtectiveShieldName) as? SKSpriteNode {
//                shield.position = player.position
//            }
            if let data = motionManager.accelerometerData {
                if data.acceleration.x > 0.02 {
                    //player.physicsBody!.applyForce(CGVector(dx: 30 * CGFloat(data.acceleration.x), dy: 0))
                    //player.physicsBody?.velocity.dx = CGFloat(120 * ((data.acceleration.x * 10) * (data.acceleration.x * 1.25)))
                    // Disabled Acceleration
                    player.physicsBody?.velocity.dx = CGFloat(120 * (data.acceleration.x * 10)) * CGFloat(playerMovingDirection)
                }
                if data.acceleration.x < -0.02 {
                    //player.physicsBody!.applyForce(CGVector(dx: 30 * CGFloat(data.acceleration.x), dy: 0))
                    //player.physicsBody?.velocity.dx = CGFloat(120 * ((data.acceleration.x * 10) * (data.acceleration.x * -1.25)))
                    // Disabled Acceleration
                    player.physicsBody?.velocity.dx = CGFloat(120 * (data.acceleration.x * 10)) * CGFloat(playerMovingDirection)
                }
                if data.acceleration.x < 0.02 && data.acceleration.x > -0.02 {
                    player.physicsBody?.velocity.dx = 0.0
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        timeCounter = timeCounter + 1
        updateBackground()
        processUserMotion()
        GameData.shared.playerScore = GameData.shared.playerScore + 1
        updateHud()
        let timeSinceLastFired = currentTime - lastFiredTime
        // Only fire weapon if the weapon hasn't been fired in the last fireRate seconds and the user is touching the screen
        if timeSinceLastFired > fireRate && touchingScreen && playerAlive {
            firePlayerWeapon()
            lastFiredTime = currentTime
        }
        // Sets all nodes damaged by explosion to be able to be damaged again.
        if !damagedByPlayerMissileExplosionArray.isEmpty {
            for child in self.children {
                if child.name != nil && damagedByPlayerMissileExplosionArray.contains(child.name!){
                    child.userData?.setValue(false, forKey: "invulnerable")
                }
            }
        }
        playerTempInvulnerable = false
        
        // Spawns the first boss eyeBoss, if it hasn't been spawned before and enough time has passed - 100 seconds
        if !eyeBossSpawned && timeCounter >= timeToSpawnNextBoss  {
            setUpEyeBoss()
        }
        // Spawns the second boss if it hasen't been spawned before, eyeBoss has been killed and enought time has passed - 100 seconds
        if !boss2Spawned && eyeBossDefeated && timeCounter >= (timeToSpawnNextBoss + timeEyeBossDefeated) {
            setUpBoss2()
        }
        // Spawns the third boss if it hasen't been spawned before, eyeBoss has been killed, boss2 has been killed, and enought time has passed - 100 seconds
        if !boss3Spawned && boss2Defeated && eyeBossDefeated && timeCounter >= (timeToSpawnNextBoss + timeBoss2Defeated) {
            setUpBoss3()
        }
        
        // eyeBoss moves and attacks after it has finished moving into position and has its physics body initialized
        if eyeBossFullySpawned {
            processEyeBossMovement(forUpdate: currentTime)
            if(currentTime - timeEyeBossAttack) >= eyeBossAttackRate {
                timeEyeBossAttack = currentTime
                processEyeBossAttacks(attackChosen: Int(arc4random_uniform(2) + 1))
            }
            if let eyeBossLaser = childNode(withName: kEyeBossLaserName) as? SKSpriteNode {
                if let player = childNode(withName: kPlayerName) as? SKSpriteNode {
                    if player.position.x + 17.5 > eyeBossLaser.position.x - 10 && player.position.x - 17.5 < eyeBossLaser.position.x + 10 {
                        playerTakesDamage(damage: 12, view: view!)
                    }
                }
            }
        }
        if !playerAlive {
            let wait = SKAction.wait(forDuration:2.6)
            let action = SKAction.run {
                gameOver(view: self.view!)
            }
            run(SKAction.sequence([wait,action]))
        }
        if boss2FullySpawned {
            processBoss2Movement()
            if(currentTime - timeBoss2Attack) >= boss2AttackRate {
                timeBoss2Attack = currentTime
                boss2Attack()
            }
        }
        if boss3FullySpawned && boss3Phase2 {
            processBoss3Phase2Movement()
            if(currentTime - timeBoss3Attack) >= boss3AttackRate {
                timeBoss3Attack = currentTime
                processBoss3Phase2Attacks(attackChosen: Int(arc4random_uniform(3) + 1))
            }
        }
        if !alienMissileArray.isEmpty {
            processAlienMissileMovement()
        }
        if !homingMissileArray.isEmpty {
            processHomingMissileMovement()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingScreen = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchingScreen = false
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if pauseButton.contains(touchLocation) {
            playButtonPress()
            pauseButton.removeFromParent()
            createPauseNode()
            GameScene.sharedInstance.isPaused = true
        }
        if unpauseButton != nil && unpauseButton.contains(touchLocation) {
            playButtonPress()
            removePauseNode()
            createPauseButton()
            GameScene.sharedInstance.isPaused = false
        }
        
        if muteButton != nil && muteButton.contains(touchLocation) {
            playButtonPress()
            gameMuted = !gameMuted
            if gameMuted {
                muteButton.texture = SKTexture(imageNamed: "sound-off")
                GameData.shared.bgMusicPlayer.pause()
            } else {
                muteButton.texture = SKTexture(imageNamed: "sound-on")
                GameData.shared.bgMusicPlayer.play()
            }
        }
        
        if retryButton != nil && retryButton.contains(touchLocation) {
            playButtonPress()
            resetGameData()
            gameSceneLoad(view: view!)
        }
        if menuButton != nil && menuButton.contains(touchLocation) {
            playButtonPress()
            resetGameData()
            startSceneLoad(view: view!)
        }
        
    }
    
    // Called when there is a collision between two nodes.
    func collisionBetween(ob1: SKNode, ob2: SKNode){
        if !protectiveShieldActive {
            if ob1.name == kPlayerName && ob2.name == kAlienName {
                explosionEffect(position: ob2.position, fileName: "AlienExplosionParticle.sks", score: 0, sound: "")
                ob2.removeFromParent()
                playerTakesDamage(damage: 40, view: view!)
            }
            if ob1.name == kPlayerName && ob2.name == kMassiveAsteroidName {
                explosionEffect(position: ob2.position, fileName: "AsteroidExplosionParticle.sks", score: 0, sound: "")
                playerTakesDamage(damage: 1000, view: view!)
            }
            if ob1.name == kPlayerName && ob2.name == kLargeAsteroidName {
                explosionEffect(position: ob2.position, fileName: "AsteroidExplosionParticle.sks", score: 0, sound: "")
                addMediumAsteroid(position: ob2.position, xoffset: -10)
                addMediumAsteroid(position: ob2.position, xoffset: 10)
                ob2.removeFromParent()
                playerTakesDamage(damage: 90, view: view!)
            }
            if ob1.name == kPlayerName && ob2.name == kMediumAsteroidName {
                explosionEffect(position: ob2.position, fileName: "AsteroidExplosionMediumParticle.sks", score: 0, sound: "")
                addSmallAsteroid(position: ob2.position, xoffset: -5)
                addSmallAsteroid(position: ob2.position, xoffset: 5)
                ob2.removeFromParent()
                playerTakesDamage(damage: 45, view: view!)
            }
            if ob1.name == kPlayerName && ob2.name == kSmallAsteroidName {
                explosionEffect(position: ob2.position, fileName: "AsteroidExplosionSmallParticle.sks", score: 0, sound: "")
                ob2.removeFromParent()
                playerTakesDamage(damage: 20, view: view!)
            }
            if ob1.name == kPlayerName && ob2.name == kAlienLaserName {
                 explosionEffect(position: ob2.position, fileName: "AlienLaserHitParticle.sks", score: 0, sound: "")
                ob2.removeFromParent()
                playerTakesDamage(damage: 25, view: view!)
            }
            if ob1.name == kPlayerName && ob2.name == kAlienMissileName {
                explosionEffect(position: ob2.position, fileName: "AlienMissileExplosionParticle.sks", score: 0, sound: "")
                alienMissileArray.remove(at: alienMissileArray.index(of: ob2 as! SKSpriteNode)!)
                ob2.removeFromParent()
                playerTakesDamage(damage: 65, view: view!)
            }
            if ob1.name == kPlayerName && ob2.name == kEyeBossName {
                playerTakesDamage(damage: 80, view: view!)
            }
            if ob1.name == kPlayerName && ob2.name == kPlasmaName {
                explosionEffect(position: ob2.position, fileName: "PlasmaExplosionParticle.sks", score: 0, sound: "")
                ob2.removeFromParent()
                playerTakesDamage(damage: 35, view: view!)
            }
            if ob1.name == kPlayerName && ob2.name == kBloodProjectileName {
                explosionEffect(position: ob2.position, fileName: "BloodProjectileHitParticle.sks", score: 0, sound: "")
                ob2.removeFromParent()
                playerTakesDamage(damage: 90, view: view!)
            }
        }
        if ob1.name == kProtectiveShieldName && ob2.name == kAlienName {
            explosionEffect(position: ob2.position, fileName: "AlienExplosionParticle.sks", score: 0, sound: "")
            ob2.removeFromParent()
            subtractHealth(sprite: ob1, damage: 40)
        }
        if ob1.name == kProtectiveShieldName && ob2.name == kMassiveAsteroidName {
            explosionEffect(position: ob2.position, fileName: "AsteroidExplosionParticle.sks", score: 0, sound: "")
            subtractHealth(sprite: ob1, damage: 1000)
        }
        if ob1.name == kProtectiveShieldName && ob2.name == kLargeAsteroidName {
            explosionEffect(position: ob2.position, fileName: "AsteroidExplosionParticle.sks", score: 0, sound: "")
            addMediumAsteroid(position: ob2.position, xoffset: -10)
            addMediumAsteroid(position: ob2.position, xoffset: 10)
            ob2.removeFromParent()
            subtractHealth(sprite: ob1, damage: 90)
        }
        if ob1.name == kProtectiveShieldName && ob2.name == kMediumAsteroidName {
            explosionEffect(position: ob2.position, fileName: "AsteroidExplosionMediumParticle.sks", score: 0, sound: "")
            addSmallAsteroid(position: ob2.position, xoffset: -5)
            addSmallAsteroid(position: ob2.position, xoffset: 5)
            ob2.removeFromParent()
            subtractHealth(sprite: ob1, damage: 45)
        }
        if ob1.name == kProtectiveShieldName && ob2.name == kSmallAsteroidName {
            explosionEffect(position: ob2.position, fileName: "AsteroidExplosionSmallParticle.sks", score: 0, sound: "")
            ob2.removeFromParent()
            subtractHealth(sprite: ob1, damage: 20)
        }
        if ob1.name == kProtectiveShieldName && ob2.name == kAlienLaserName {
            explosionEffect(position: ob2.position, fileName: "AlienLaserHitParticle.sks", score: 0, sound: "")
            ob2.removeFromParent()
            subtractHealth(sprite: ob1, damage: 25)
        }
        if ob1.name == kProtectiveShieldName && ob2.name == kAlienMissileName {
            explosionEffect(position: ob2.position, fileName: "AlienMissileExplosionParticle.sks", score: 0, sound: "")
            alienMissileArray.remove(at: alienMissileArray.index(of: ob2 as! SKSpriteNode)!)
            ob2.removeFromParent()
            subtractHealth(sprite: ob1, damage: 65)
        }
        if ob1.name == kProtectiveShieldName && ob2.name == kEyeBossName {
            subtractHealth(sprite: ob1, damage: 80)
        }
        if ob1.name == kProtectiveShieldName && ob2.name == kPlasmaName {
            ob2.removeFromParent()
            subtractHealth(sprite: ob1, damage: 70)
            explosionEffect(position: ob2.position, fileName: "PlasmaExplosionParticle.sks", score: 0, sound: "")
        }
        if ob1.name == kProtectiveShieldName && ob2.name == kBloodProjectileName {
            explosionEffect(position: ob2.position, fileName: "BloodProjectileHitParticle.sks", score: 0, sound: "")
            ob2.removeFromParent()
            subtractHealth(sprite: ob1, damage: 90)
        }
        
        if ob1.name == kPlayerName && ob2.name == kHealthPackName {
            playPowerUpSound()
            ob2.removeFromParent()
            GameData.shared.playerHealth = GameData.shared.maxPlayerHealth
        }
        
        if ob1.name == kPlayerName && ob2.name == kFireRateUpgradeName {
            playPowerUpSound()
            ob2.removeFromParent()
            fireRateUpgradeNumber = fireRateUpgradeNumber + 1
            setupWeapon()
        }
        
        if ob1.name == kPlayerName && ob2.name == kThreeShotUpgradeName {
            playPowerUpSound()
            ob2.removeFromParent()
            if fourShotUpgrade {
                fiveShotUpgrade = true
            }
            if threeShotUpgrade {
                fourShotUpgrade = true
            }
            if twoShotUpgrade {
                threeShotUpgrade = true
            }
            twoShotUpgrade = true
        }
        
        if ob1.name == kPlayerName && ob2.name == kProtectiveShieldUpgradeName {
            playPowerUpSound()
            ob2.removeFromParent()
            if !protectiveShieldActive {
                addProtectiveShield()
            } else {
                updateProtectiveShield()
            }
        }
        
        if ob1.name == kPlayerName && ob2.name == kHomingMissileUpgradeName {
            ob1.removeAction(forKey: "missile")
            if numberOfHomingMissileUpgrades < 5 {
                numberOfHomingMissileUpgrades = numberOfHomingMissileUpgrades + 1
            }
            playPowerUpSound()
            ob2.removeFromParent()
            setUpHomingMissile()
        }
        
        if ob1.name == kPlayerName && ob2.name == kLaserDamageUpgradeName {
            ob2.removeFromParent()
            playPowerUpSound()
            if laserDamageUpgradeNumber <= 5 {
                laserDamageUpgradeNumber = laserDamageUpgradeNumber + 1
            }
        }
        
        if ob1.name == kPlayerName && ob2.name == kMissileExplosionDamageUpgradeName {
            ob2.removeFromParent()
            playPowerUpSound()
            if missileExplosionDamageUpgradeNumber <= 5 {
                missileExplosionDamageUpgradeNumber = missileExplosionDamageUpgradeNumber + 1
                // TODO: Change colour of explosion?
            }
        }
        
        if ob1.name == kPlayerName && ob2.name == kMissileExplosionSizeUpgradeName {
            ob2.removeFromParent()
            playPowerUpSound()
            if largerExplosionUpgradeNumber <= 5 {
                largerExplosionUpgradeNumber = largerExplosionUpgradeNumber + 1
            }
        }
        
        
        if damagedByPlayerLaserArray.contains(ob1.name!) && ob2.name == kLaserName {
            subtractHealth(sprite: ob1, damage: CGFloat(laserBaseDamage * (1.0 + laserDamageUpgradeNumber * 0.2)))
            ob2.removeFromParent()
        }
        
        if damagedByPlayerMissileArray.contains(ob1.name!) && ob2.name == kMissileName {
            subtractHealth(sprite: ob1, damage: 1)
            ob2.removeFromParent()
            missileExplosion(missile: ob2)
            missileExplosionEffect(position: ob2.position)
        }
        
        if damagedByPlayerMissileArray.contains(ob1.name!) && ob2.name == kHomingMissileName {
            subtractHealth(sprite: ob1, damage: 1)
            homingMissileArray.remove(at: homingMissileArray.index(of: ob2 as! SKSpriteNode)!)
            ob2.removeFromParent()
            missileExplosion(missile: ob2)
            missileExplosionEffect(position: ob2.position)
        }
        
        if damagedByPlayerMissileExplosionArray.contains(ob1.name!) && ob2.name == kMissileExplosionName && ob1.userData?.value(forKey: "invulnerable") as? Bool != true {
            ob1.userData?.setValue(true, forKey: "invulnerable")
            if [kMassiveAsteroidName, kLargeAsteroidName, kMediumAsteroidName, kSmallAsteroidName].contains(ob1.name!) {
                subtractHealth(sprite: ob1, damage: CGFloat(2.0 * missileExplosionBaseDamage * (1.0 + missileExplosionDamageUpgradeNumber * 0.2)))
            } else {
                subtractHealth(sprite: ob1, damage: CGFloat(missileExplosionBaseDamage * (1.0 + missileExplosionDamageUpgradeNumber * 0.2)))
            }
        }
        
        if ob1.name == kEyeBossLaserName && ob2.name == kMissileName {
            ob2.removeFromParent()
            missileExplosion(missile: ob2)
            missileExplosionEffect(position: ob2.position)
        }
        if ob1.name == kEyeBossLaserName && ob2.name == kHomingMissileName {
            homingMissileArray.remove(at: homingMissileArray.index(of: ob2 as! SKSpriteNode)!)
            ob2.removeFromParent()
            missileExplosion(missile: ob2)
            missileExplosionEffect(position: ob2.position)
        }
        if ob1.name == kEyeBossLaserName && ob2.name == kLittleEyeName {
            explosionEffect(position: ob2.position, fileName: "LittleEyeExplosionParticle.sks", score: 0, sound: "littleEyePop")
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
        
        if nodeA.name == kProtectiveShieldName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kProtectiveShieldName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kAlienName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kAlienName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kMassiveAsteroidName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kMassiveAsteroidName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kLargeAsteroidName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kLargeAsteroidName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kMediumAsteroidName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kMediumAsteroidName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kSmallAsteroidName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kSmallAsteroidName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kAlienCruiserName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kAlienCruiserName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kEyeBossName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kEyeBossName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kLittleEyeName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kLittleEyeName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kEyeBossLaserName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kEyeBossLaserName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kBoss2Name {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kBoss2Name {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kHeavyAlienName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kHeavyAlienName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kBoss3Phase1Name {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kBoss3Phase1Name {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kHarvesterName {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kHarvesterName {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
        
        if nodeA.name == kBoss3Phase2Name {
            collisionBetween(ob1: nodeA, ob2: nodeB)
        } else if nodeB.name == kBoss3Phase2Name {
            collisionBetween(ob1: nodeB, ob2: nodeA)
        }
    }
    
}
