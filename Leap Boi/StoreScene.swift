//
//  StoreScene.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-03-09.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion


class StoreScene: SKScene {
    let background = SKSpriteNode(imageNamed: "starbackground")
    var backButton: SKSpriteNode! = nil
    var healthUpgradeButton: SKSpriteNode! = nil
    var shieldHealthUpgradeButton: SKSpriteNode! = nil
    var shieldDurationUpgradeButton: SKSpriteNode! = nil
    var doubleLaserUpgradeButton: SKSpriteNode! = nil
    var homingMissileUpgradeButton: SKSpriteNode! = nil
    var magnetUpgradeButton: SKSpriteNode! = nil
    var startLootUpgradeButton: SKSpriteNode! = nil
    var inappPurchaseButton: SKSpriteNode! = nil
    var creditsLabel: SKLabelNode! = nil
    
    override func didMove(to view: SKView) {
        scene?.scaleMode = .aspectFit
        createBackground()
        createUI()
    }

    func createBackground() {
        let background = SKSpriteNode(imageNamed: "starbackground")
        background.zPosition = 1
        background.size = CGSize(width: background.size.width, height: frame.size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
    }
    
    func createUI() {
        let upgradeButtonWidth = size.width - 30
        let upgradeButtonHeight = upgradeButtonWidth * 0.1557496361
        createCreditsLabel()
        createBackButton()
        createHealthUpgradeButton(width: upgradeButtonWidth, height: upgradeButtonHeight)
        createShieldHealthUpgradeButton(width: upgradeButtonWidth, height: upgradeButtonHeight)
        createShieldDurationUpgradeButton(width: upgradeButtonWidth, height: upgradeButtonHeight)
        createDoubleLaserUpgradeButton(width: upgradeButtonWidth, height: upgradeButtonHeight)
        createHomingMissileUpgradeButton(width: upgradeButtonWidth, height: upgradeButtonHeight)
        createMagnetUpgradeButton(width: upgradeButtonWidth, height: upgradeButtonHeight)
        createStartBoxUpgradeButton(width: upgradeButtonWidth, height: upgradeButtonHeight)
        
        let inappPurchaseButtonWidth = size.width - backButton.size.width - 50
        let inappPurchaseButtonHeight = inappPurchaseButtonWidth * 0.1557496361
        createPurchaseButton(width: inappPurchaseButtonWidth, height: inappPurchaseButtonHeight)
    }
    
    func createBackButton() {
        backButton = SKSpriteNode(imageNamed: "back")
        backButton.zPosition = 2
        backButton.size = CGSize(width: 64, height: 64)
        backButton.position = CGPoint(x: backButton.frame.size.width / 2 + 20, y: backButton.frame.size.height / 2 + 20)
        addChild(backButton)
    }
    
    func createCreditsLabel() {
        creditsLabel = SKLabelNode(fontNamed: "SquareFont")
        creditsLabel.zPosition = 2
        creditsLabel.fontSize = 25
        creditsLabel.fontColor = SKColor.white
        creditsLabel.text = "Credits: \(GameData.shared.totalCredits)"
        creditsLabel.position = CGPoint(x: size.width/2, y: size.height - 40)
        self.addChild(creditsLabel)
    }
    
    func createHealthUpgradeButton(width: CGFloat, height: CGFloat) {
        healthUpgradeButton = SKSpriteNode(imageNamed: "button_increase_max_hp")
        healthUpgradeButton.zPosition = 2
        healthUpgradeButton.size = CGSize(width: width, height: height)
        //healthUpgradeButton.position = CGPoint(x: size.width / 2, y: size.height * (5.2/6))
        healthUpgradeButton.position = creditsLabel.position - CGPoint(x: 0, y: healthUpgradeButton.size.height + 20)
        addChild(healthUpgradeButton)
    }
    
    func createShieldHealthUpgradeButton(width: CGFloat, height: CGFloat) {
        shieldHealthUpgradeButton = SKSpriteNode(imageNamed: "button_increase_shield_amount")
        shieldHealthUpgradeButton.zPosition = 2
        shieldHealthUpgradeButton.size = CGSize(width: width, height: height)
        shieldHealthUpgradeButton.position = healthUpgradeButton.position - CGPoint(x: 0, y: healthUpgradeButton.size.height + 20)
        addChild(shieldHealthUpgradeButton)
    }
    
    func createShieldDurationUpgradeButton(width: CGFloat, height: CGFloat) {
        shieldDurationUpgradeButton = SKSpriteNode(imageNamed: "button_increase_shield_duration")
        shieldDurationUpgradeButton.zPosition = 2
        shieldDurationUpgradeButton.size = CGSize(width: width, height: height)
        shieldDurationUpgradeButton.position = shieldHealthUpgradeButton.position - CGPoint(x: 0, y: shieldHealthUpgradeButton.size.height + 20)
        addChild(shieldDurationUpgradeButton)
    }
    
    func createDoubleLaserUpgradeButton(width: CGFloat, height: CGFloat) {
        doubleLaserUpgradeButton = SKSpriteNode(imageNamed: "button_double_laser")
        doubleLaserUpgradeButton.zPosition = 2
        doubleLaserUpgradeButton.size = CGSize(width: width, height: height)
        doubleLaserUpgradeButton.position = shieldDurationUpgradeButton.position - CGPoint(x: 0, y: shieldDurationUpgradeButton.size.height + 20)
        addChild(doubleLaserUpgradeButton)
    }
    
    func createHomingMissileUpgradeButton(width: CGFloat, height: CGFloat) {
        homingMissileUpgradeButton = SKSpriteNode(imageNamed: "button_homing_missile")
        homingMissileUpgradeButton.zPosition = 2
        homingMissileUpgradeButton.size = CGSize(width: width, height: height)
        homingMissileUpgradeButton.position = doubleLaserUpgradeButton.position - CGPoint(x: 0, y: doubleLaserUpgradeButton.size.height + 20)
        addChild(homingMissileUpgradeButton)
    }
    
    func createMagnetUpgradeButton(width: CGFloat, height: CGFloat) {
        // TODO: Create the button and effect. Upgrades will move towards the player
        magnetUpgradeButton = SKSpriteNode(imageNamed: "button_upgrade_magnet")
        magnetUpgradeButton.zPosition = 2
        magnetUpgradeButton.size = CGSize(width: width, height: height)
        magnetUpgradeButton.position = homingMissileUpgradeButton.position - CGPoint(x: 0, y: homingMissileUpgradeButton.size.height + 20)
        addChild(magnetUpgradeButton)
    }
    
    func createStartBoxUpgradeButton(width: CGFloat, height: CGFloat) {
        startLootUpgradeButton = SKSpriteNode(imageNamed: "button_start_loot")
        startLootUpgradeButton.zPosition = 2
        startLootUpgradeButton.size = CGSize(width: width, height: height)
        startLootUpgradeButton.position = magnetUpgradeButton.position - CGPoint(x: 0, y: magnetUpgradeButton.size.height + 20)
        addChild(startLootUpgradeButton)
    }
    
    func createPurchaseButton(width: CGFloat, height: CGFloat) {
        inappPurchaseButton = SKSpriteNode(imageNamed: "button_purchase_credits")
        inappPurchaseButton.zPosition = 2
        inappPurchaseButton.size = CGSize(width: width, height: height)
        inappPurchaseButton.position = backButton.position + CGPoint(x: 50 + inappPurchaseButton.size.width/2, y: 0)
        addChild(inappPurchaseButton)
    }
    
    func createInappPurchaseNode() {
        // TODO: This http://blogs.quickheal.com/wp-content/uploads/2014/07/in-app-purchase.jpg
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if backButton.contains(touchLocation) {
            playButtonPress()
            startSceneLoad(view: view!)
        }
        if healthUpgradeButton.contains(touchLocation) {
            playButtonPress()
            let costToUpgrade = 1000 + GameData.shared.numberOfHealthUpgrades * 1000
            let alert = UIAlertController(title: "Upgrade Max HP by 20?", message: "Credits: \(costToUpgrade)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                NSLog("The \"NO\" alert occured.")
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                NSLog("The \"Yes\" alert occured.")
                if GameData.shared.totalCredits < costToUpgrade {
                    let notEnoughCreditsAlert = UIAlertController(title: "Not Enough Credits", message: "Credits are earned by playing or can be purchased", preferredStyle: .alert)
                    notEnoughCreditsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(notEnoughCreditsAlert, animated: true, completion: nil)
                } else {
                    GameData.shared.totalCredits = GameData.shared.totalCredits - costToUpgrade
                    GameData.shared.numberOfHealthUpgrades = GameData.shared.numberOfHealthUpgrades + 1
                    UserDefaults.standard.setUserHealthUpgrades(numberOfHealthUpgrades: GameData.shared.numberOfHealthUpgrades)
                    UserDefaults.standard.setUserCredits(credits: GameData.shared.totalCredits)
                    self.creditsLabel.text = "Credits: \(GameData.shared.totalCredits)"
                    let newHealth = 100 + 20 * UserDefaults.standard.getUserHealthUpgrades()
                    let purchaseAlert = UIAlertController(title: "HP increased to \(newHealth)!", message: "Remaining Credit Balance: \(GameData.shared.totalCredits)", preferredStyle: .alert)
                    purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(purchaseAlert, animated: true, completion: nil)
                }
            }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        if shieldHealthUpgradeButton.contains(touchLocation) {
            playButtonPress()
            let costToUpgrade = 1000 + GameData.shared.numberOfShieldHealthUpgrades * 1000
            let alert = UIAlertController(title: "Increase shield by 20?", message: "Credits: \(costToUpgrade)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                NSLog("The \"NO\" alert occured.")
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                NSLog("The \"Yes\" alert occured.")
                if GameData.shared.totalCredits < costToUpgrade {
                    let notEnoughCreditsAlert = UIAlertController(title: "Not Enough Credits", message: "Credits are earned by playing or can be purchased", preferredStyle: .alert)
                    notEnoughCreditsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(notEnoughCreditsAlert, animated: true, completion: nil)
                } else {
                    GameData.shared.totalCredits = GameData.shared.totalCredits - costToUpgrade
                    GameData.shared.numberOfShieldHealthUpgrades = GameData.shared.numberOfShieldHealthUpgrades + 1
                    UserDefaults.standard.setUserShieldHealthUpgrades(numberOfShieldHealthUpgrades: GameData.shared.numberOfShieldHealthUpgrades)
                    UserDefaults.standard.setUserCredits(credits: GameData.shared.totalCredits)
                    self.creditsLabel.text = "Credits: \(GameData.shared.totalCredits)"
                    let newShieldAmount = 100 + 20 * UserDefaults.standard.getUserShieldHealthUpgrades()
                    let purchaseAlert = UIAlertController(title: "Shield amount increased to \(newShieldAmount)!", message: "Remaining Credit Balance: \(GameData.shared.totalCredits)", preferredStyle: .alert)
                    purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(purchaseAlert, animated: true, completion: nil)
                }
            }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        if shieldDurationUpgradeButton.contains(touchLocation) {
            playButtonPress()
            let costToUpgrade = 1000 + GameData.shared.numberOfShieldDurationUpgrades * 1000
            let alert = UIAlertController(title: "Increase shield duration by 5 seconds?", message: "Credits: \(costToUpgrade)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                NSLog("The \"NO\" alert occured.")
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                NSLog("The \"Yes\" alert occured.")
                if GameData.shared.totalCredits < costToUpgrade {
                    let notEnoughCreditsAlert = UIAlertController(title: "Not Enough Credits", message: "Credits are earned by playing or can be purchased", preferredStyle: .alert)
                    notEnoughCreditsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(notEnoughCreditsAlert, animated: true, completion: nil)
                } else {
                    GameData.shared.totalCredits = GameData.shared.totalCredits - costToUpgrade
                    GameData.shared.numberOfShieldDurationUpgrades = GameData.shared.numberOfShieldDurationUpgrades + 1
                    UserDefaults.standard.setUserShieldDurationUpgrades(numberOfShieldDurationUpgrades: GameData.shared.numberOfShieldDurationUpgrades)
                    UserDefaults.standard.setUserCredits(credits: GameData.shared.totalCredits)
                    self.creditsLabel.text = "Credits: \(GameData.shared.totalCredits)"
                    let newShieldDuration = 10 + 5 * UserDefaults.standard.getUserShieldDurationUpgrades()
                    let purchaseAlert = UIAlertController(title: "Shield duration increased to \(newShieldDuration) seconds!", message: "Remaining Credit Balance: \(GameData.shared.totalCredits)", preferredStyle: .alert)
                    purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(purchaseAlert, animated: true, completion: nil)
                }
            }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        if doubleLaserUpgradeButton.contains(touchLocation) {
            playButtonPress()
            let costToUpgrade = 10000
            let alert = UIAlertController(title: "Start with two lasers instead of one", message: "Credits: \(costToUpgrade)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                NSLog("The \"NO\" alert occured.")
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                NSLog("The \"Yes\" alert occured.")
                if GameData.shared.doubleLaserUpgrade {
                    let alreadyUpgraded = UIAlertController(title: "You have already purchased this upgrade", message: "", preferredStyle: .alert)
                    alreadyUpgraded.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(alreadyUpgraded, animated: true, completion: nil)
                } else if GameData.shared.totalCredits < costToUpgrade {
                    let notEnoughCreditsAlert = UIAlertController(title: "Not Enough Credits", message: "Credits are earned by playing or can be purchased", preferredStyle: .alert)
                    notEnoughCreditsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(notEnoughCreditsAlert, animated: true, completion: nil)
                } else {
                    GameData.shared.totalCredits = GameData.shared.totalCredits - costToUpgrade
                    GameData.shared.doubleLaserUpgrade = true
                    UserDefaults.standard.setUserDoubleLaserUpgrade(doubleLaser: true)
                    UserDefaults.standard.setUserCredits(credits: GameData.shared.totalCredits)
                    self.creditsLabel.text = "Credits: \(GameData.shared.totalCredits)"
                    let purchaseAlert = UIAlertController(title: "You now start with two lasers!", message: "Remaining Credit Balance: \(GameData.shared.totalCredits)", preferredStyle: .alert)
                    purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(purchaseAlert, animated: true, completion: nil)
                }
            }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        if homingMissileUpgradeButton.contains(touchLocation) {
            playButtonPress()
            let costToUpgrade = 10000
            let alert = UIAlertController(title: "Start with one upgrade into homing missiles when using missiles", message: "Credits: \(costToUpgrade)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                NSLog("The \"NO\" alert occured.")
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                NSLog("The \"Yes\" alert occured.")
                if GameData.shared.homingMissileUpgrade {
                    let alreadyUpgraded = UIAlertController(title: "You have already purchased this upgrade", message: "", preferredStyle: .alert)
                    alreadyUpgraded.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(alreadyUpgraded, animated: true, completion: nil)
                } else if GameData.shared.totalCredits < costToUpgrade {
                    let notEnoughCreditsAlert = UIAlertController(title: "Not Enough Credits", message: "Credits are earned by playing or can be purchased", preferredStyle: .alert)
                    notEnoughCreditsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(notEnoughCreditsAlert, animated: true, completion: nil)
                } else {
                    GameData.shared.totalCredits = GameData.shared.totalCredits - costToUpgrade
                    GameData.shared.homingMissileUpgrade = true
                    UserDefaults.standard.setUserHomingMissileUpgrade(homingMissile: true)
                    UserDefaults.standard.setUserCredits(credits: GameData.shared.totalCredits)
                    self.creditsLabel.text = "Credits: \(GameData.shared.totalCredits)"
                    let purchaseAlert = UIAlertController(title: "You now start with homing missiles!", message: "Remaining Credit Balance: \(GameData.shared.totalCredits)", preferredStyle: .alert)
                    purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(purchaseAlert, animated: true, completion: nil)
                }
            }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        if magnetUpgradeButton.contains(touchLocation) {
            playButtonPress()
            let costToUpgrade = 10000
            let alert = UIAlertController(title: "Upgrades will gravitate towards you", message: "Credits: \(costToUpgrade)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                NSLog("The \"NO\" alert occured.")
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                NSLog("The \"Yes\" alert occured.")
                if GameData.shared.magnetUpgrade {
                    let alreadyUpgraded = UIAlertController(title: "You have already purchased this upgrade", message: "", preferredStyle: .alert)
                    alreadyUpgraded.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(alreadyUpgraded, animated: true, completion: nil)
                } else if GameData.shared.totalCredits < costToUpgrade {
                    let notEnoughCreditsAlert = UIAlertController(title: "Not Enough Credits", message: "Credits are earned by playing or can be purchased", preferredStyle: .alert)
                    notEnoughCreditsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(notEnoughCreditsAlert, animated: true, completion: nil)
                } else {
                    GameData.shared.totalCredits = GameData.shared.totalCredits - costToUpgrade
                    GameData.shared.magnetUpgrade = true
                    UserDefaults.standard.setUserMagnetUpgrade(magnet: true)
                    UserDefaults.standard.setUserCredits(credits: GameData.shared.totalCredits)
                    self.creditsLabel.text = "Credits: \(GameData.shared.totalCredits)"
                    let purchaseAlert = UIAlertController(title: "Upgrades will now gravitate towards you!", message: "Remaining Credit Balance: \(GameData.shared.totalCredits)", preferredStyle: .alert)
                    purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(purchaseAlert, animated: true, completion: nil)
                }
            }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        if startLootUpgradeButton.contains(touchLocation) {
            playButtonPress()
            let costToUpgrade = 10000
            let alert = UIAlertController(title: "Start each game with a random spawn of upgrades", message: "Credits: \(costToUpgrade)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                NSLog("The \"NO\" alert occured.")
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                NSLog("The \"Yes\" alert occured.")
                
                if GameData.shared.startUpgradeBox {
                    let alreadyUpgraded = UIAlertController(title: "You have already purchased this upgrade", message: "", preferredStyle: .alert)
                    alreadyUpgraded.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(alreadyUpgraded, animated: true, completion: nil)
                } else if GameData.shared.totalCredits < costToUpgrade {
                    let notEnoughCreditsAlert = UIAlertController(title: "Not Enough Credits", message: "Credits are earned by playing or can be purchased", preferredStyle: .alert)
                    notEnoughCreditsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(notEnoughCreditsAlert, animated: true, completion: nil)
                } else {
                    GameData.shared.totalCredits = GameData.shared.totalCredits - costToUpgrade
                    GameData.shared.startUpgradeBox = true
                    UserDefaults.standard.setUserStartBoxUpgrade(startBox: true)
                    UserDefaults.standard.setUserCredits(credits: GameData.shared.totalCredits)
                    self.creditsLabel.text = "Credits: \(GameData.shared.totalCredits)"
                    let purchaseAlert = UIAlertController(title: "You will now start each game with a random spawn of upgrades!", message: "Remaining Credit Balance: \(GameData.shared.totalCredits)", preferredStyle: .alert)
                    purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(purchaseAlert, animated: true, completion: nil)
                }
            }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
        if inappPurchaseButton.contains(touchLocation) {
            playButtonPress()
            createInappPurchaseNode()
        }
    }
}

