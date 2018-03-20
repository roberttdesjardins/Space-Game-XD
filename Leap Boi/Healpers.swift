//
//  Healpers.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-02-27.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import Foundation
import AVFoundation

private var warningPlayer: AVAudioPlayer!
private var buttonSoundPlayer: AVAudioPlayer!

func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
}

func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
}


func setAlienHealth(alien: SKSpriteNode) {
    alien.userData?.setValue(3.0, forKey: "health")
}

func setLargeAsteroidHealth(asteroid: SKSpriteNode) {
    asteroid.userData?.setValue(10.0, forKey: "health")
}

func setMediumAsteroidHealth(asteroid: SKSpriteNode) {
    asteroid.userData?.setValue(5.0, forKey: "health")
}

func setSmallAsteroidHealth(asteroid: SKSpriteNode) {
    asteroid.userData?.setValue(2.0, forKey: "health")
}

func setAlienCruiserHealth(alienCruiser: SKSpriteNode) {
    alienCruiser.userData?.setValue(200.0, forKey: "health")
}

func setEyeBossHealth(eyeBoss: SKSpriteNode) {
    eyeBoss.userData?.setValue(400.0, forKey: "health")
}

func setLittleEyeHealth(littleEye: SKSpriteNode) {
    littleEye.userData?.setValue(8.0, forKey: "health")
}

func setBoss2Health(boss2: SKSpriteNode) {
    boss2.userData?.setValue(800.0, forKey: "health")
}

func setHeavyAlienHealth(heavyAlien: SKSpriteNode) {
    heavyAlien.userData?.setValue(400.0, forKey: "health")
}

func setBoss3Phase1Health(boss3: SKSpriteNode) {
    boss3.userData?.setValue(1000.0, forKey: "health")
}

func setHarvesterHealth(harvester: SKSpriteNode) {
    harvester.userData?.setValue(80.0, forKey: "health")
}

func setBoss3Phase2Health(boss3: SKSpriteNode) {
    boss3.userData?.setValue(1600.0, forKey: "health")
}

func setShieldHealth(shield: SKSpriteNode) {
    shield.userData?.setValue(GameData.shared.shieldAmount, forKey: "health")
}

func gameOver(view: UIView) {
    warningPlayer?.stop()
    let scene = GameOverScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
}

func winSceneLoad(view: UIView) {
    let scene = WinGameOverScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
}

func startSceneLoad(view: UIView) {
    let scene = StartScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.presentScene(scene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
}

func gameSceneLoad(view: UIView) {
    let scene = GameScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.showsFPS = true
    skView.showsNodeCount = true
    skView.presentScene(scene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
}

func storeSceneLoad(view: UIView) {
    let scene = StoreScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
}

func highScoreSceneLoad(view: UIView) {
    let scene = HighScoreScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
}

func weaponSceneLoad(view: UIView) {
    let scene = WeaponScene(size: view.bounds.size)
    let skView = view as! SKView
    skView.ignoresSiblingOrder = true
    scene.scaleMode = .resizeFill
    skView.showsFPS = false
    skView.showsNodeCount = false
    skView.presentScene(scene, transition: SKTransition.doorsOpenHorizontal(withDuration: 1.0))
}

func warningFlashing(scene: SKScene){
    
    let path = Bundle.main.path(forResource: "warningBeep", ofType: "wav")!
    let url = URL(fileURLWithPath: path)
    do {
        warningPlayer = try AVAudioPlayer(contentsOf: url)
        warningPlayer.numberOfLoops = 6
        warningPlayer.prepareToPlay()
    } catch let error as NSError {
        print(error.description)
    }
    warningPlayer.play()
    
    let warningSign = SKSpriteNode(imageNamed: "warning")
    warningSign.zPosition = 2
    warningSign.size = CGSize(width: 40, height: 40)
    warningSign.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
    scene.addChild(warningSign)
    
    
    let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.645)
    let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.645)
    let pulse = SKAction.sequence([fadeIn, fadeOut])
    let pulseTenTimes = SKAction.sequence([SKAction.repeat(pulse,count: 7), fadeOut, SKAction.removeFromParent()])
    warningSign.run(pulseTenTimes)
}

func angleToRotateToWhileFacingDown(adjacent: CGFloat, opposite: CGFloat) -> CGFloat {
    if adjacent <= 0 && opposite >= 0 {
        // Quadrant 2
        return atan(opposite/adjacent) - 90 * DegreesToRadians
    }
    // Quadrants 1, 3 and 4
    return atan2(opposite, adjacent) + 90 * DegreesToRadians
}


func faceTowards(sprite1: SKSpriteNode, sprite2: SKSpriteNode) -> CGFloat {
    let adjacent = sprite2.position.x - sprite1.position.x
    let opposite = sprite2.position.y - sprite1.position.y
    return angleToRotateToWhileFacingDown(adjacent: adjacent, opposite: opposite)
}

func resetGameData() {
    GameData.shared.playerScore = 0
    GameData.shared.creditsEarned = 0
    //GameData.shared.playerHealth = GameData.shared.maxPlayerHealth
}


func formatHighScores(arrayOfScores: [Int]) {
    GameData.shared.playerHighScore = quicksort(arrayOfScores)
    GameData.shared.playerHighScore = Array(GameData.shared.playerHighScore.prefix(5))
}

func playButtonPress() {
    let path = Bundle.main.path(forResource: "Free-GUI-Buttons-039", ofType: "wav")!
    let url = URL(fileURLWithPath: path)
    do {
        buttonSoundPlayer = try AVAudioPlayer(contentsOf: url)
        buttonSoundPlayer.numberOfLoops = 0
        buttonSoundPlayer.prepareToPlay()
    } catch let error as NSError {
        print(error.description)
    }
    buttonSoundPlayer.play()
}

func quicksort<T: Comparable>(_ a: [T]) -> [T] {
    guard a.count > 1 else { return a }
    
    let pivot = a[a.count/2]
    let less = a.filter { $0 < pivot }
    let equal = a.filter { $0 == pivot }
    let greater = a.filter { $0 > pivot }
    
    return quicksort(greater) + equal + quicksort(less)
}

