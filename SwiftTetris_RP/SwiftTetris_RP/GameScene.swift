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
    
    private var gameplayPaused = false
    private let gameplayContainer = SKNode()
    
    private let numRows = 20
    private let numCols = 10
    private let minimumCellSize: CGFloat = 24.0
    
    private var gridNodes: [[SKSpriteNode?]] = []
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        addChild(gameplayContainer)
        
        // Get label node from gameplayContainer and store it for use later
        self.label = gameplayContainer.childNode(withName: "//helloLabel") as? SKLabelNode
        self.basicSquare = gameplayContainer.childNode(withName: "//basicSquare") as? SKShapeNode
        self.pauseButton = self.childNode(withName: "//pauseButton") as? SKShapeNode
        self.pauseLabel = self.childNode(withName: "//pauseLabel") as? SKLabelNode

        // Create shape node to use during mouse interaction and add to gameplayContainer
        let w = (self.size.width + self.size.height) * 0.05
        let spinny = SKShapeNode(rectOf: CGSize(width: w, height: w), cornerRadius: w * 0.3)
        self.spinnyNode = spinny
        gameplayContainer.addChild(spinny)

        // Prepare nextShape and scoreArea under gameplayContainer if they exist
        if let next = self.childNode(withName: "//nextShape") as? SKShapeNode {
            nextShape = next
            next.removeFromParent()
            gameplayContainer.addChild(next)
        }
        if let score = self.childNode(withName: "//scoreArea") as? SKShapeNode {
            scoreArea = score
            score.removeFromParent()
            gameplayContainer.addChild(score)
        }
        
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
        setupTetrisGrid()
    }
    
    private func setupTetrisGrid() {
        guard let basicSquare = basicSquare else {
            print("Error: basicSquare not found in scene.")
            return
        }

        // Add uniform padding around the grid inside basicSquare
        let paddingRatio: CGFloat = 0.05
        let insetX = basicSquare.frame.width * paddingRatio
        let insetY = basicSquare.frame.height * paddingRatio
        let insetRect = basicSquare.frame.insetBy(dx: insetX, dy: insetY)

        let cellWidth = insetRect.width / CGFloat(numCols)
        let cellHeight = insetRect.height / CGFloat(numRows)

        // Clear old nodes if necessary
        gridNodes.removeAll()

        for row in 0..<numRows {
            var rowArray: [SKSpriteNode?] = []
            for col in 0..<numCols {
                let block = SKSpriteNode(color: .darkGray, size: CGSize(width: cellWidth - 1, height: cellHeight - 1))
                let x = insetRect.minX + CGFloat(col) * cellWidth + cellWidth / 2
                let y = insetRect.minY + CGFloat(row) * cellHeight + cellHeight / 2
                block.position = CGPoint(x: x, y: y)
                gameplayContainer.addChild(block)
                rowArray.append(block)
            }
            gridNodes.append(rowArray)
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
       
    }
    
    func touchMoved(toPoint pos : CGPoint) {
       
    }
    
    func touchUp(atPoint pos : CGPoint) {
       
    }
    
    func handlePause() {
        gameplayPaused.toggle()
        gameplayContainer.isPaused = gameplayPaused
        print("Game is now \(gameplayPaused ? "paused" : "resumed")")

        if gameplayPaused {
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
