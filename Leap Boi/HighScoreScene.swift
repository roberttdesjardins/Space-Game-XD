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
    let background = SKSpriteNode(imageNamed: "starbackground")
    var backButton: SKSpriteNode! = nil
    var highScoreBackground: SKSpriteNode! = nil
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        createBackground()
        createHighScoreTable()
        createBackButton()
    }
    
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "starbackground")
        background.zPosition = 1
        background.size = CGSize(width: background.size.width, height: frame.size.height)
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
    }
    
    func createBackButton() {
        backButton = SKSpriteNode(imageNamed: "back")
        backButton.zPosition = 2
        backButton.size = CGSize(width: 64, height: 64)
        backButton.position = CGPoint(x: backButton.frame.size.width / 2 + 20, y: backButton.frame.size.height / 2 + 20)
        addChild(backButton)
    }
    
    
    func createHighScoreTable() {
        let highScoreTable = SKLabelNode(fontNamed: "SquareFont")
        highScoreTable.fontSize = 35
        highScoreTable.zPosition = 5
        highScoreTable.fontColor = SKColor.white
        highScoreTable.numberOfLines = 11
        highScoreTable.text = "High Scores:\n"
        for highScore in GameData.shared.playerHighScore {
            highScoreTable.text?.append("\(highScore)\n")
        }
        highScoreTable.position = CGPoint(x: self.size.width/2, y: self.size.height/2 - highScoreTable.frame.size.height/2)
        
        self.addChild(highScoreTable)
        
        let scoreBGWidth = size.width - 80
        let scoreBGHeight = scoreBGWidth * 1.3042596349
        highScoreBackground = SKSpriteNode(imageNamed: "vertical-medium")
        highScoreBackground.zPosition = 2
        highScoreBackground.size = CGSize(width: scoreBGWidth, height: scoreBGHeight)
        highScoreBackground.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(highScoreBackground)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)
        if backButton.contains(touchLocation) {
            playButtonPress()
            startSceneLoad(view: view!)
        }
    }

}
