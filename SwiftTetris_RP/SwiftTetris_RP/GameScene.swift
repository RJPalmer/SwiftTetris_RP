//
//  GameScene.swift
//  SwiftTetris_RP
//
//  Created by Robert Palmer on 4/10/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

private var scoreManager = GameScoreManager()

required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    print("GameScene: init(coder:) called")
}

override init(size: CGSize) {
    super.init(size: size)
    print("GameScene: init(size:) called")
}

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
private var scoreTextLabel: SKLabelNode?
private var scoreValueLabel: SKLabelNode?
private var pauseMenu: SKNode?
private var blurNode: SKEffectNode?

private var gameplayPaused = false
private let gameplayContainer = SKNode()

internal var numRows: Int {
    let value = UserDefaults.standard.integer(forKey: "NumRows")
    return value == 0 ? 20 : value
} // Default to 20 rows if not set
internal var numCols: Int{
    let value = UserDefaults.standard.integer(forKey: "NumCols")
    return value == 0 ? 10 : value
} // Default to 10 columns if not set
private let minimumCellSize: CGFloat = 24.0

private var gridNodes: [[SKSpriteNode?]] = []
private var lockedBlocks: [[SKShapeNode?]] = []

private var activeTetromino: Tetromino?
private var upcomingTetrominoType: TetrominoType?

override func sceneDidLoad() {
    super.sceneDidLoad()
    print("GameScene: sceneDidLoad() called")

    self.lastUpdateTime = 0
    addChild(gameplayContainer)
    
    // Get label node from gameplayContainer and store it for use later
    self.label = gameplayContainer.childNode(withName: "//helloLabel") as? SKLabelNode
    if let basic = self.childNode(withName: "//basicSquare") as? SKShapeNode {
        basicSquare = basic
        basic.removeFromParent()
        gameplayContainer.addChild(basic)
    }
//        self.nextShape = self.childNode(withName: "//nextShape") as? SKShapeNode
    self.pauseButton = self.childNode(withName: "//pauseButton") as? SKShapeNode
    self.pauseLabel = self.childNode(withName: "//pauseLabel") as? SKLabelNode

    // Create shape node to use during mouse interaction and add to gameplayContainer
    let w = (self.size.width + self.size.height) * 0.05
    let spinny = SKShapeNode(rectOf: CGSize(width: w, height: w), cornerRadius: w * 0.3)
    self.spinnyNode = spinny
    gameplayContainer.addChild(spinny)

    // Prepare nextShape and scoreArea under gameplayContainer if they exist
    if let node = self.childNode(withName: "//nextShape") {
        if let next = node as? SKShapeNode {
            nextShape = next
            next.removeFromParent()
            gameplayContainer.addChild(next)
        } else {
            print("Warning: nextShape exists but is not an SKShapeNode")
        }
    } else {
        print("Warning: nextShape not found in scene")
    }
    if let score = self.childNode(withName: "//scoreArea") as? SKShapeNode {
        scoreArea = score
        score.removeFromParent()
        gameplayContainer.addChild(score)
    }
    if let area = scoreArea {
        scoreTextLabel = SKLabelNode(text: "Score:")
        scoreTextLabel?.fontName = "Helvetica-Bold"
        scoreTextLabel?.fontSize = 16
        scoreTextLabel?.fontColor = .white
        scoreTextLabel?.horizontalAlignmentMode = .center
        scoreTextLabel?.verticalAlignmentMode = .bottom
        scoreTextLabel?.position = CGPoint(x: 0, y: 55) // Align with "Next:"
        area.addChild(scoreTextLabel!)

        scoreValueLabel = SKLabelNode(text: "0")
        scoreValueLabel?.fontName = "Helvetica-Bold"
        scoreValueLabel?.fontSize = 36
        scoreValueLabel?.fontColor = .white
        scoreValueLabel?.horizontalAlignmentMode = .center
        scoreValueLabel?.verticalAlignmentMode = .top
        scoreValueLabel?.position = CGPoint(x: 0, y: 15) // Align with preview block
        area.addChild(scoreValueLabel!)
    }
    
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
    print("Children in scene:", self.children.map { $0.name ?? "nil" })
    setupTetrisGrid()
    spawnTetromino()

    // Print all child nodes at the end to reflect the final scene state
    self.enumerateChildNodes(withName: "*") { node, _ in
        print("Found node:", node.name ?? "nil")
    }

    // Log node lifecycle for initial snapshot
    logNodeLifecycle()
}

override func didMove(to view: SKView) {
    super.didMove(to: view)
    print("GameScene: didMove(to:) called")
    if basicSquare == nil {
        print("Reinitializing scene due to nil basicSquare")
        sceneDidLoad()
    }
}

@objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
    if gesture.direction == .down {
        // removed fast dropping behavior
    }
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
    lockedBlocks = Array(repeating: Array<SKShapeNode?>(repeating: nil, count: numCols), count: numRows)

    // Log node lifecycle after grid setup
    logNodeLifecycle()
}

// MARK: - Debug Node Lifecycle
private func logNodeLifecycle() {
    print("--- Node Lifecycle ---")
    print("basicSquare exists:", basicSquare != nil)
    print("basicSquare in parent:", basicSquare?.parent != nil)
    print("Children of gameplayContainer:", gameplayContainer.children.map { $0.name ?? "unnamed" })
    print("Children of scene:", self.children.map { $0.name ?? "unnamed" })
}

private func spawnTetromino() {
    activeTetromino?.remove(from: gameplayContainer)

    let type: TetrominoType
    if let nextType = upcomingTetrominoType {
        type = nextType
    } else {
        type = TetrominoType.allCases.randomElement()!
    }
    let origin = (row: type.spawnOffsetRow(numRows: numRows), col: numCols / 2)

    for (dx, dy) in type.blocks {
        let row = origin.row + dy
        let col = origin.col + dx

        if row >= 0 && row < numRows && col >= 0 && col < numCols {
            if lockedBlocks[row][col] != nil {
                handleGameOver()
                return
            }
        }
    }

    activeTetromino = Tetromino(type: type, origin: origin, grid: gridNodes, container: gameplayContainer)
    upcomingTetrominoType = TetrominoType.allCases.randomElement()!
    displayNextTetromino()
}

private func displayNextTetromino() {
    nextShape?.removeAllChildren()
    guard let shape = nextShape, let type = upcomingTetrominoType else { return }
    
    
    let blockSize: CGFloat = min(shape.frame.width, shape.frame.height) / 15.0

    let label = SKLabelNode(text: "Next:")
    label.fontName = "Helvetica-Bold"
    label.fontSize = blockSize
    label.fontColor = .white
    label.verticalAlignmentMode = .bottom
    label.position = CGPoint(x: 0, y: blockSize * 3.5)
    label.name = "nextLabel"
    shape.addChild(label)
    
    for (dx, dy) in type.blocks {
        let block = SKShapeNode(rectOf: CGSize(width: blockSize - 2, height: blockSize - 2), cornerRadius: 2)
        block.fillColor = .white
        block.strokeColor = .gray
        block.name = "previewBlock"

        // Position in node-local space, centered at (0, 0), with vertical offset upwards
        let x = CGFloat(dx) * blockSize
        let y = CGFloat(-dy) * blockSize + blockSize * 2
        block.position = CGPoint(x: x, y: y)

        shape.addChild(block)
    }
}

    private func updateScoreDisplay() {
        scoreValueLabel?.text = "\(scoreManager.score)"
    }
    
private func canMoveTetrominoDown() -> Bool {
    guard let tetromino = activeTetromino else { return false }

    for (dx, dy) in tetromino.offsets {
        let newRow = tetromino.origin.row + dy - 1
        let col = tetromino.origin.col + dx

        if newRow < 0 || newRow >= numRows || col < 0 || col >= numCols {
            return false
        }

        if lockedBlocks[newRow][col] != nil {
            return false
        }
    }

    return true
}

private func moveTetrominoDown() {
    let fallDistance = gridNodes[0][0]?.size.height ?? 0
    if canMoveTetrominoDown() {
        activeTetromino?.moveDown(by: fallDistance)
    } else {
        lockTetromino()
        spawnTetromino()
    }
}

private func lockTetromino() {
    guard let tetromino = activeTetromino else { return }

    for (index, (dx, dy)) in tetromino.offsets.enumerated() {
        let row = tetromino.origin.row + dy
        let col = tetromino.origin.col + dx
        if row >= 0 && row < numRows && col >= 0 && col < numCols && index < tetromino.blocks.count {
            lockedBlocks[row][col] = tetromino.blocks[index]
        }
    }

    // Add scoring for tetromino landing
    scoreManager.addTetrominoLanding()

    activeTetromino = nil
    clearCompletedLines()
    updateScoreDisplay()
}

// Clear completed lines, shift down, and update grid
private func clearCompletedLines() {
    var newLockedBlocks: [[SKShapeNode?]] = Array(
        repeating: Array(repeating: nil, count: numCols),
        count: numRows
    )

    var newRow = 0
    var clearCount = 0
    for row in 0..<numRows {
        let isComplete = lockedBlocks[row].allSatisfy { $0 != nil }

        if !isComplete {
            newLockedBlocks[newRow] = lockedBlocks[row]
            
            for col in 0..<numCols {
                if let node = newLockedBlocks[newRow][col] {
                    if let targetBlock = gridNodes[newRow][col] {
                        node.position = targetBlock.position
                    }
                }
            }
            newRow += 1
        } else {
            for col in 0..<numCols {
                lockedBlocks[row][col]?.removeFromParent()
            }
            // Count lines cleared this turn
           clearCount += 1
           
            
        }
    }
    //let linesClearedThisTurn = newRow - lockedBlocks.count + numRows
    scoreManager.addLinesCleared(clearCount)

    lockedBlocks = newLockedBlocks
    updateScoreDisplay()
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

        // Tetromino rotation: tap directly on any block of the active tetromino
        if let blocks = activeTetromino?.blocks {
            for block in blocks {
                if block.contains(location) {
                    rotateTetromino()
                    return
                }
            }
        }

        // Left/right movement control
        let screenMidX = self.frame.midX
        let isLeftSide = location.x < screenMidX
        let isRightSide = location.x > screenMidX
        let cellWidth = gridNodes[0][0]?.size.width ?? 0
        if isLeftSide {
            activeTetromino?.moveHorizontally(by: -1, cellWidth: cellWidth, numCols: numCols)
        } else if isRightSide {
            activeTetromino?.moveHorizontally(by: 1, cellWidth: cellWidth, numCols: numCols)
        }

        touchDown(atPoint: location)
    }
    
//        if let label = self.label {
//            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//        }
}

// Tetromino rotation logic
private func rotateTetromino() {
    guard let tetromino = activeTetromino else { return }

    let origin = tetromino.origin
    // Use tetromino.offsets instead of tetromino.type.blocks
    let newOffsets = tetromino.offsets.map { (x, y) in (-y, x) }
    var newPositions: [(row: Int, col: Int)] = []

    for (dx, dy) in newOffsets {
        let newRow = origin.row + dy
        let newCol = origin.col + dx

        if newRow < 0 || newRow >= numRows || newCol < 0 || newCol >= numCols {
            return // out of bounds
        }
        if lockedBlocks[newRow][newCol] != nil {
            return // collides
        }
        newPositions.append((newRow, newCol))
    }

    for (i, position) in newPositions.enumerated() {
        if let targetBlock = gridNodes[position.row][position.col] {
            tetromino.blocks[i].position = targetBlock.position
        }
    }

    // Apply rotated offsets
    tetromino.offsets = newOffsets
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
    super.update(currentTime)
    print("GameScene: update(currentTime:) called")
    if gameplayPaused || basicSquare == nil { return }  // Prevent updates while paused or if not initialized

    if self.lastUpdateTime == 0 {
        self.lastUpdateTime = currentTime
    }

    let dt = currentTime - self.lastUpdateTime

    for entity in self.entities {
        entity.update(deltaTime: dt)
    }

    fallTimer += dt
    if fallTimer >= fallInterval {
        fallTimer = 0
        moveTetrominoDown()
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

private var fallTimer: TimeInterval = 0
private var fallInterval: TimeInterval {
    // Fallback to 0.5 seconds if UserDefaults value is 0
    return UserDefaults.standard.double(forKey: "FallInterval") == 0 ? 0.5 : UserDefaults.standard.double(forKey: "FallInterval")
}
private func handleGameOver() {
    print("Game Over!")
    gameplayPaused = true
    gameplayContainer.isPaused = true

    let label = SKLabelNode(text: "GAME OVER")
    label.fontName = "Courier-Bold"
    label.fontSize = 32
    label.fontColor = .red
    label.position = CGPoint(x: frame.midX, y: frame.midY)
    label.zPosition = 2000
    addChild(label)
}
}

extension TetrominoType {
    func spawnOffsetRow(numRows: Int) -> Int {
        switch self {
        case .I: return numRows - 4
        case .O: return numRows - 2
        case .T, .L, .J, .S, .Z: return numRows - 3
        }
    }
}
