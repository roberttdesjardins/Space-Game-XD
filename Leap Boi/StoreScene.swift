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
    var backButton: SKNode! = nil
    var healthUpgradeButton: SKNode! = nil
    var creditsLabel: SKLabelNode! = nil
    
    override func didMove(to view: SKView) {
        createBackground()
        createBackButton()
        createHealthUpgradeButton()
        createCreditsLabel()
    }
    
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "starbackground")
        background.zPosition = 1
        background.size = CGSize(width: background.size.width, height: frame.size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
    }
    
    func createBackButton() {
        backButton = SKSpriteNode(imageNamed: "backButton")
        backButton.zPosition = 2
        backButton.position = CGPoint(x: backButton.frame.size.width / 2 + 20, y: backButton.frame.size.height / 2 + 20)
        addChild(backButton)
    }
    
    func createCreditsLabel() {
        creditsLabel = SKLabelNode(fontNamed: "Avenir")
        creditsLabel.zPosition = 2
        creditsLabel.fontSize = 25
        creditsLabel.fontColor = SKColor.white
        creditsLabel.text = "Credits: \(GameData.shared.totalCredits)"
        creditsLabel.position = CGPoint(x: size.width/2, y: size.height - 40)
        self.addChild(creditsLabel)
    }
    
    func createHealthUpgradeButton() {
        healthUpgradeButton = SKSpriteNode(imageNamed: "increaseMaxHpButton")
        healthUpgradeButton.zPosition = 2
        healthUpgradeButton.position = CGPoint(x: size.width / 2, y: size.height * (5/6))
        addChild(healthUpgradeButton)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if backButton.contains(touchLocation) {
            startSceneLoad(view: view!)
        }
        if healthUpgradeButton.contains(touchLocation) {
            let costToUpgrade = 1000 + GameData.shared.numberOfHealthUpgrades * 1000
            let alert = UIAlertController(title: "Upgrade Max HP by 50?", message: "Credits: \(costToUpgrade)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
                NSLog("The \"NO\" alert occured.")
            }))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                NSLog("The \"Yes\" alert occured.")
                if GameData.shared.totalCredits <= costToUpgrade {
                    let notEnoughCreditsAlert = UIAlertController(title: "Not Enough Credits", message: "Credits are earned by playing or can be purchased", preferredStyle: .alert)
                    notEnoughCreditsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.view?.window?.rootViewController?.present(notEnoughCreditsAlert, animated: true, completion: nil)
                } else {
                    GameData.shared.totalCredits = GameData.shared.totalCredits - costToUpgrade
                    GameData.shared.numberOfHealthUpgrades = GameData.shared.numberOfHealthUpgrades + 1
                    UserDefaults.standard.setUserHealthUpgrades(numberOfHealthUpgrades: GameData.shared.numberOfHealthUpgrades)
                    UserDefaults.standard.setUserCredits(credits: GameData.shared.totalCredits)
                    self.creditsLabel = nil
                    self.createCreditsLabel()
                    //TODO: Sound? Notification?
                }
            }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

