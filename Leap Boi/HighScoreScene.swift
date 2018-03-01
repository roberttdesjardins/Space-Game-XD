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
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        createHighScoreTable()
        createBackButton()
    }
    
    func createBackButton() {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        backButton.titleLabel?.textAlignment = NSTextAlignment.center
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.borderWidth = 5
        backButton.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        backButton.layer.cornerRadius = 10
        backButton.clipsToBounds = true
        backButton.setTitle("< Back", for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        
        self.view?.addSubview(backButton)
    }
    
    @objc func backButtonAction(sender: UIButton!) {
        for locView in (self.view?.subviews)! {
            locView.removeFromSuperview()
        }
        startSceneLoad(view: view!)
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

}
