//
//  GameScene.swift
//  Knives-Chicken-and-Salad
//
//  Created by james luo on 9/6/18.
//  Copyright © 2018 james luo. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var possibleFood = ["Peach","Chicken","Watermellon"]
    var inPlay = false
    private var Startlabel : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var knife : SKSpriteNode?
    override func didMove(to view: SKView) {
        Startlabel = self.childNode(withName: "helloLabel") as? SKLabelNode
        knife = self.childNode(withName: "knife") as? SKSpriteNode
        // Get label node from scene and store it for use later
        
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
    }
    func startGame (){
        inPlay = false
        Startlabel?.isHidden = true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!inPlay){
            startGame()
            return
        }
        for touch in touches{
            let location = touch.location(in: self)
            knife?.run(SKAction.moveTo(x: location.x, duration: 0.1))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            knife?.run(SKAction.moveTo(x: location.x, duration: 0.1))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    @objc func addFood(){
        possibleFood = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleFood) as! [String]
        let food = SKSpriteNode(imageNamed: possibleFood[0])
        
    }
}
