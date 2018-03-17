//
//  HighScoreScene.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-03-01.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion


class HighScoreScene: SKScene {
    var backButton: SKSpriteNode! = nil
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        createHighScoreTable()
        createBackButton()
    }
    
    func createBackButton() {
        backButton = SKSpriteNode(imageNamed: "back")
        backButton.zPosition = 2
        backButton.size = CGSize(width: 64, height: 64)
        backButton.position = CGPoint(x: backButton.frame.size.width / 2 + 20, y: backButton.frame.size.height / 2 + 20)
        addChild(backButton)
    }
    
    
    func createHighScoreTable() {
        let highScoreTable = SKLabelNode(fontNamed: "Avenir")
        highScoreTable.fontSize = 35
        highScoreTable.fontColor = SKColor.white
        highScoreTable.numberOfLines = 11
        highScoreTable.text = "High Scores:\n"
        for highScore in GameData.shared.playerHighScore {
            highScoreTable.text?.append("\(highScore)\n")
        }
        highScoreTable.position = CGPoint(x: self.size.width/2, y: self.size.height/2 - highScoreTable.frame.size.height/2)
        
        self.addChild(highScoreTable)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if backButton.contains(touchLocation) {
            startSceneLoad(view: view!)
        }
    }

}
