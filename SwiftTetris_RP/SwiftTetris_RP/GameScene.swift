//
//  GameScene.swift
//  SwiftTetris_RP
//
//  Created by Robert Palmer on 4/10/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var basicSquare : SKShapeNode?
    private var nextShape : SKShapeNode?
    private var scoreArea : SKShapeNode?
    private var pauseButton : SKShapeNode?
    private var pauseLabel: SKLabelNode?
    private var pauseMenu: SKNode?
    private var blurNode: SKEffectNode?
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        self.basicSquare = self.childNode(withName: "//basicSquare") as? SKShapeNode
        self.pauseButton = self.childNode(withName: "//pauseButton") as? SKShapeNode
        self.pauseLabel = self.childNode(withName: "//pauseLabel") as? SKLabelNode
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//            
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
       
    }
    
    func touchUp(atPoint pos : CGPoint) {
       
    }
    
    func handlePause() {
        isPaused.toggle()
        print("Game is now \(isPaused ? "paused" : "resumed")")

        if isPaused {
            showPauseMenu()
        } else {
            pauseMenu?.removeFromParent()
            blurNode?.removeFromParent()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)

            if let node = self.atPoint(location) as? SKLabelNode, node.name == "resumeButton" {
                handlePause()
                return
            }

//            if let pause = pauseLabel, pause.contains(location) {
//                handlePause()
//                return
//            }
//            
            if let pause = pauseButton, pause.contains(location){
                handlePause()
                return
            }

            touchDown(atPoint: location)
        }
        
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
    
    private func showPauseMenu() {
        let blur = SKEffectNode()
        blur.shouldRasterize = true
        let blurFilter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 5.0])
        blur.filter = blurFilter
        blur.zPosition = 999
        blur.position = CGPoint(x: frame.midX, y: frame.midY)
        blur.blendMode = .alpha
        addChild(blur)
        blurNode = blur
        
        let menu = SKNode()
        menu.zPosition = 1000

        let background = SKShapeNode(rectOf: CGSize(width: 250, height: 150), cornerRadius: 12)
        background.fillColor = .black
        background.alpha = 0.8
        menu.addChild(background)

        let label = SKLabelNode(text: "Paused")
        label.fontName = "Courier-Bold"
        label.fontSize = 24
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 30)
        menu.addChild(label)

        let resumeLabel = SKLabelNode(text: "Resume")
        resumeLabel.name = "resumeButton"
        resumeLabel.fontName = "Courier-Bold"
        resumeLabel.fontSize = 20
        resumeLabel.fontColor = .yellow
        resumeLabel.position = CGPoint(x: 0, y: -30)
        menu.addChild(resumeLabel)

        menu.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(menu)
        pauseMenu = menu
    }
}
