//
//  StartScene.swift
//  Leap Boi
//
//  Created by Robert Desjardins on 2018-02-27.
//  Copyright © 2018 Robert Desjardins. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class StartScene: SKScene {
    
    override func didMove(to view: SKView) {
        let tapLabel = SKLabelNode(fontNamed: "Avenir")
        tapLabel.fontSize = 25
        tapLabel.fontColor = SKColor.white
        tapLabel.text = "Tap to Start"
        tapLabel.position = CGPoint(x: self.size.width/2, y: 2.0 / 3.0 * self.size.height);
        self.addChild(tapLabel)
        self.backgroundColor = SKColor.black
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)  {
        
        let gameScene = GameScene(size: self.size)
        gameScene.scaleMode = .aspectFill
        view?.showsFPS = true
        view?.showsNodeCount = true
        view?.ignoresSiblingOrder = true
        self.view?.presentScene(gameScene, transition: SKTransition.doorsCloseHorizontal(withDuration: 1.0))
        
    }
}

