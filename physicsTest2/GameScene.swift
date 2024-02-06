//
//  GameScene.swift
//  physicsTest2
//
//  Created by Krish Bothra on 1/19/24.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player = SKSpriteNode()
    var spike = SKSpriteNode()

    let terrain = SKShapeNode(rectOf: CGSize(width: 500, height: 30))
    
    var startTouch = CGPoint()
    var endTouch = CGPoint()
    var motionManager: CMMotionManager!
    
    var changePos = false;
    var timer: Timer?
    
    var score: Int = 0;
    
    var spikeA: [SKSpriteNode] = [];

    var scoreCount: SKLabelNode!
    
    var rampUp: Double = 0.5;
    var minS: Int = 0;
    var maxS: Int = 5;
    var speedFall: Double = 1.0;
    
    var button = SKSpriteNode()
    let buttonTexture = SKTexture(imageNamed: "button_default")
    let buttonHighlightedTexture = SKTexture(imageNamed: "button_highlighted")

    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self

        self.backgroundColor = .lightGray

            // Set the scale mode to .aspectFit
        self.scaleMode = .aspectFit
            
            // Create a physics body representing an edge loop from the scene's frame
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    
        resetGravityOfPhysicsWorldToZero()
        backgroundColor = .lightGray
        player = SKSpriteNode(imageNamed: "Marble")
        player.size = CGSize(width: 75, height: 75)
        player.physicsBody = SKPhysicsBody(circleOfRadius: 14)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false;
        player.position = .init(x:0, y:0)
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = PhysicsCategory.spike
        player.physicsBody?.contactTestBitMask = PhysicsCategory.spike
        player.name = "player"
        
        addChild(player)
        
//        terrain.strokeColor = .black
//        terrain.fillColor = .black
//        terrain.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 500, height: 30))
//        terrain.physicsBody?.affectedByGravity = false
//        terrain.physicsBody?.isDynamic = false
//        terrain.position = .init(x:0, y:-200)
        
        // Create a label
        scoreCount = SKLabelNode(text: String(score))
        scoreCount.fontSize = 75
        scoreCount.fontColor = .black
        scoreCount.position = CGPoint(x: 300, y: 500)
        scoreCount.horizontalAlignmentMode = .right
        scoreCount.verticalAlignmentMode = .top
        
        addChild(scoreCount)
        
        
        motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        
//        addChild(terrain)
        button = SKSpriteNode(texture: buttonTexture)
        button.name = "button" // Assign a name to the button for identification
        button.isHidden = true;
        addChild(button)

        startTimer()
        
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()

        
        if contact.bodyA.node?.name == "player" {
            
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
       

        
        if firstBody.node?.name == "player" && secondBody.node?.name == "spike" {
            print("Contact Detected")
            changePos = true;
            button.isHidden = false;
            button.position.x = 0
            button.position.y = 0;
        }
        
    }
    
    func touchDown(_ touches: Set<UITouch>, with event: UIEvent) {
        
    }
    
    func touchMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        
    }
    
    func touchUp(_ touches: Set<UITouch>, with event: UIEvent) {
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            // Check if the touched node is the button
            if node.name == "button" {
                // Button is tapped
                if let buttonNode = node as? SKSpriteNode {
                    buttonNode.texture = buttonHighlightedTexture
                    resetGame()
                    // Perform button action
                }
            }
        }
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            endTouch = touch.location(in: self)
        }
        
        
//        resetGravityOfPhysicsWorldToZero()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
#if targetEnvironment(simulator)
    if let currentTouch = lastTouchPosition {
        let diff = CGPoint(x: currentTouch.x - player.position.x, y: currentTouch.y - player.position.y)
        physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
    }
#else
    if let accelerometerData = motionManager.accelerometerData {
        let accelerationVector = CGVector(dx: accelerometerData.acceleration.x * 75, dy: accelerometerData.acceleration.y * 0)

            // Apply the vector directly to the player's position
            player.position.x += accelerationVector.dx

            // Get the size of the scene
            let sceneSize = self.size

            // Clamp the player's position to stay within the bounds of the scene
        if player.position.x>361.8 {
            player.position.x = 361.8
        }
        else if player.position.x<(-361.8){
            player.position.x = (-361.8)
        }
//        print("Player Position: \(player.position)")

//        player.position.x = max(min(player.position.x, sceneSize.width)+50, -(sceneSize.width)-50)
            player.position.y = max(min(player.position.y, sceneSize.height), 0)
    }
#endif
        
        for i in (0..<spikeA.count).reversed() {
            if spikeA[i].position.y < -500 {
                score += 1
                scoreCount.text = String(score)
                
                // Remove the sprite from the array
                
                // Remove the sprite from the parent
                spikeA[i].removeFromParent()
                spikeA.remove(at: i)

            }
        }
        
        if(score>=maxS){
            minS = score;
            maxS += 5
            if(rampUp>=0.25){
                rampUp -= 0.05
                startTimer()
                print(String(rampUp))
            }
        }
        speedFall = 1*rampUp
        print(String(speedFall))

        
        
        
        
        
        
    }
    
    func resetGravityOfPhysicsWorldToZero() {
//        physicsWorld.gravity = .zero
    }
    
    func startTimer() {
        timer?.invalidate()
            
        timer = Timer.scheduledTimer(timeInterval: (speedFall), target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    
    @objc func timerFired() {
        if !changePos {
            spikeItem();
//            score+=1;
//            scoreCount = SKLabelNode(text: String(score))
            print(String(score))
           
                        
            
        }else{
            backgroundColor = .red
            for i in (0..<spikeA.count).reversed() {
                spikeA[i].removeFromParent()
                spikeA.remove(at: i)

                
            }
        }
    
    }
    
    func spikeItem(){
        
        let randomNumber = Int(arc4random_uniform(721)) - 360
        
        spike = SKSpriteNode(imageNamed: "Spike")
        spike.size = CGSize(width: 75, height: 75)
        spike.physicsBody = SKPhysicsBody(rectangleOf: spike.size )
        spike.physicsBody?.affectedByGravity = true
        spike.physicsBody?.isDynamic = true
        spike.physicsBody?.allowsRotation = false;
        spike.position = .init(x:randomNumber, y:500)
        spike.physicsBody?.categoryBitMask = PhysicsCategory.spike
        spike.name = "spike";
        spikeA.append(spike)
        addChild(spike)
    }
    
    func resetGame(){
        player.position = .init(x:0, y:0)
//        spike.position = .init(x: 0, y: 200)
        changePos = false;
        score = 0;
        scoreCount.text = String(score)
        backgroundColor = .lightGray
        rampUp = 0.5
        speedFall = 1*rampUp
        minS = 0;
        maxS = 5;
        button.isHidden = true;
    }
}
