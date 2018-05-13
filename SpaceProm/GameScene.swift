//
//  GameScene.swift
//  SpacegameReloaded
//
//  Created by Training on 01/10/2016.
//  Copyright © 2016 Training. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameOver = true
    var starfield:SKEmitterNode!
    var player:SKSpriteNode!
    var win = false
    var timeLabel:SKLabelNode!
    var timeLeft:Int = 0
    var gameTimer:Timer!
    var timeRemaining:Timer!
    var possibleAliens = ["alien", "alien2", "alien3"]
    let winCatagory:UInt32 = 0x1 << 0
    let objectCategory:UInt32 = 0x1 << 1
    //let photonTorpedoCategory:UInt32 = 0x1 << 1
    
    
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    
    override func didMove(to view: SKView) {
        timeLabel = SKLabelNode(text: "ETA:" + String(timeLeft))
        starfield = SKEmitterNode(fileNamed: "Starfield")
        player = SKSpriteNode(imageNamed: "shuttle")
        starfield.position = CGPoint(x: 0, y: 1472)
        starfield.advanceSimulationTime(10)
        self.addChild(starfield)
        
        starfield.zPosition = -1
        let startLable = SKLabelNode(text: "Tap to Launch")
        startLable.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        self.addChild(startLable)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        timeRemaining = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data:CMAccelerometerData?, error:Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
        
        
        
    }
    
    @objc func updateTime(){
        if win || gameOver{
            return
        }
        timeLeft += -1
        if timeLeft < 0{
            player.physicsBody?.categoryBitMask = objectCategory
            player.physicsBody?.contactTestBitMask = objectCategory
            player.physicsBody?.collisionBitMask = objectCategory
            win = true
            let winLabel = SKLabelNode(text: "You made it to Space Prom")
            winLabel.fontName = "AmericanTypewriter-Bold"
            winLabel.fontSize = 20
            winLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
            self.addChild(winLabel)
            player.physicsBody?.usesPreciseCollisionDetection = false
        }
        self.timeLabel.text = "ETA: \(timeLeft)"
    }
    
    @objc func addAlien () {
        if win{
            let explosion = SKEmitterNode(fileNamed: "fireWorks")
            explosion?.position.y = self.frame.height / 2
            explosion?.position.x = CGFloat(arc4random_uniform(UInt32(Int(self.frame.width))))
            self.addChild(explosion!)
            self.run(SKAction.wait(forDuration: 1)) {
                explosion?.removeFromParent()
            }
            return
        }
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: 414)
        let position = CGFloat(randomAlienPosition.nextInt())
        
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height)
        
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        alien.physicsBody!.contactTestBitMask = objectCategory
        alien.physicsBody?.categoryBitMask = objectCategory
       
      //  alien.physicsBody?.collisionBitMask = 0
        alien.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(alien)
        
        let animationDuration:TimeInterval = 6
        
        var actionArray = [SKAction]()
        
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
    
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (gameOver || win){
            self.removeAllChildren()
            start()
        }
       // fireTorpedo()
    }
    func start(){
        self.win = false
        self.gameOver = false
        self.addChild(starfield)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = false
        player.name = "player"
        player.position = CGPoint(x: self.frame.size.width / 2, y: player.size.height / 2 + 20)
        //player.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = objectCategory
        player.physicsBody?.contactTestBitMask = objectCategory
        player.physicsBody?.collisionBitMask = objectCategory
        player.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(player)
        
        timeLabel = SKLabelNode(text: "ETA: 40")
        timeLabel.position = CGPoint(x: 100, y: self.frame.size.height - 60)
        timeLabel.fontName = "AmericanTypewriter-Bold"
        timeLabel.fontSize = 36
        timeLabel.fontColor = UIColor.white
        timeLeft = 40
        
        self.addChild(timeLabel)

        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
    }
    
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody:SKPhysicsBody
        var secondBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if gameOver{
            return
        }
        if win{
            if (((firstBody.node as! SKSpriteNode).name != "player")) {
                let toRemove = (firstBody.node as! SKSpriteNode)
                toRemove.removeFromParent()
            }
            if (((secondBody.node as! SKSpriteNode).name != "player")) {
                let toRemove = (secondBody.node as! SKSpriteNode)
                toRemove.removeFromParent()
            }
            return
        }
        if (firstBody.categoryBitMask) != 0 && (secondBody.categoryBitMask) != 0 {
            if (((firstBody.node as! SKSpriteNode).name == "player") || (secondBody.node as! SKSpriteNode).name == "player") {
           //torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
            playerCollide()
            }
        }
        
    }
    func playerCollide(){
        self.timeLabel.text = "ETA: Error"
        let explosion = SKEmitterNode(fileNamed: "Explosion")
        explosion?.position = self.player.position
        self.addChild(explosion!)
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        player.removeFromParent()
        self.run(SKAction.wait(forDuration: 2)) {
            explosion?.removeFromParent()
        }
        
        self.gameOver = true
        let gameoverLabel = SKLabelNode(text: "Your ride to Prom is Gone")
        self.addChild(gameoverLabel)
        gameoverLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        let tryAgainLabel = SKLabelNode(text: "Tap to try again")
        self.addChild(tryAgainLabel)
        tryAgainLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 4)
        
    }
    
    
    
    
    override func didSimulatePhysics() {
        
        player.position.x += xAcceleration * 30
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20 {
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
    }
    
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
