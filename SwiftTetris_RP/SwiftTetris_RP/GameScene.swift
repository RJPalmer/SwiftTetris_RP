//
//  GameScene.swift
//  SwiftTetris_RP
//
//  Created by Robert Palmer on 4/10/25.
//

import SpriteKit
import GameplayKit

/// The main SpriteKit scene for the Tetris game. Handles grid logic, tetromino spawning, input, score, pause, and game loop.
class GameScene: SKScene {

// MARK: - Initialization & Properties

private var scoreManager = GameScoreManager()

    /// Required initializer for SKScene loading from storyboard or nib.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("GameScene: init(coder:) called")
    }

    /// Designated initializer for SKScene with a specific size.
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

    /// Returns the number of rows for the Tetris grid (default 20).
    internal var numRows: Int {
        let value = UserDefaults.standard.integer(forKey: "NumRows")
        return value == 0 ? 20 : value
    } // Default to 20 rows if not set
    /// Returns the number of columns for the Tetris grid (default 10).
    internal var numCols: Int{
        let value = UserDefaults.standard.integer(forKey: "NumCols")
        return value == 0 ? 10 : value
    } // Default to 10 columns if not set
private let minimumCellSize: CGFloat = 24.0
    private let defaultNumRows = 20
    private let defaultNumCols = 10
    private let defaultFallInterval: TimeInterval = 0.5

private var gridNodes: [[SKSpriteNode?]] = []
private var lockedBlocks: [[SKShapeNode?]] = []

private var activeTetromino: Tetromino?
private var upcomingTetrominoType: TetrominoType?

// MARK: - Scene Initialization

    /// Called once when the scene is first loaded.
    /// Initializes all nodes, sets up the grid, and prepares the first tetromino.
    ///
    /// This method finds and configures all key nodes, sets up the Tetris grid, and spawns the first tetromino.
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

    /// Called when the scene is presented by the view.
    /// Ensures the scene is properly initialized.
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        print("GameScene: didMove(to:) called")
        if basicSquare == nil {
            print("Reinitializing scene due to nil basicSquare")
            sceneDidLoad()
        }

        // Configure SKView debug properties based on build configuration
        #if DEBUG
        view.showsFPS = true
        view.showsNodeCount = true
        #else
        view.showsFPS = false
        view.showsNodeCount = false
        #endif
    }

// MARK: - Grid Setup

    /// Sets up the Tetris grid nodes and initializes the locked blocks array.
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
/// Logs the current lifecycle state of key nodes for debugging.
private func logNodeLifecycle() {
    print("--- Node Lifecycle ---")
    print("basicSquare exists:", basicSquare != nil)
    print("basicSquare in parent:", basicSquare?.parent != nil)
    print("Children of gameplayContainer:", gameplayContainer.children.map { $0.name ?? "unnamed" })
    print("Children of scene:", self.children.map { $0.name ?? "unnamed" })
}

// MARK: - Tetromino Management

    private static let allTetrominoTypes = TetrominoType.allCases

    private func isPositionBlocked(row: Int, col: Int) -> Bool {
        guard row >= 0, row < numRows, col >= 0, col < numCols else { return true }
        return lockedBlocks[row][col] != nil
    }

    private func randomTetrominoType() -> TetrominoType {
        return GameScene.allTetrominoTypes.randomElement()!
    }

    private func spawnTetromino() {
        activeTetromino?.remove(from: gameplayContainer)

        let type = upcomingTetrominoType ?? randomTetrominoType()
        let origin = (row: type.spawnOffsetRow(numRows: numRows), col: numCols / 2)

        // Check spawn collision early
        for (dx, dy) in type.blocks {
            let row = origin.row + dy
            let col = origin.col + dx
            if isPositionBlocked(row: row, col: col) {
                handleGameOver()
                return
            }
        }

        activeTetromino = Tetromino(type: type, origin: origin, grid: gridNodes, container: gameplayContainer)
        upcomingTetrominoType = randomTetrominoType()
        displayNextTetromino()
    }

    /// Displays a preview of the next tetromino in the nextShape node.
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

    /// Updates the score label with the current score.
    private func updateScoreDisplay() {
        scoreValueLabel?.text = "\(scoreManager.score)"
    }

    /// Returns true if the active tetromino can move down without collision.
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

    /// Moves the active tetromino down by one row, or locks it if it can't move further.
    private func moveTetrominoDown() {
    let fallDistance = gridNodes[0][0]?.size.height ?? 0
    if canMoveTetrominoDown() {
        activeTetromino?.moveDown(by: fallDistance)
    } else {
        lockTetromino()
        spawnTetromino()
    }
}

    /// Locks the current tetromino into the lockedBlocks array and checks for line clears.
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

    /// Checks for and clears completed lines in the grid.
    /// Shifts all above lines down and updates the score.
    private func clearCompletedLines() {
        // Create a new array to store the resulting locked blocks after line clears
        var newLockedBlocks: [[SKShapeNode?]] = Array(
            repeating: Array(repeating: nil, count: numCols),
            count: numRows
        )

        var newRow = 0
        var clearCount = 0
        for row in 0..<numRows {
            // Check if the row is complete (all columns are filled)
            let isComplete = lockedBlocks[row].allSatisfy { $0 != nil }

            if !isComplete {
                // Copy the row to the new array
                newLockedBlocks[newRow] = lockedBlocks[row]

                // Reposition any blocks in this row to their new positions
                for col in 0..<numCols {
                    if let node = newLockedBlocks[newRow][col] {
                        if let targetBlock = gridNodes[newRow][col] {
                            node.position = targetBlock.position
                        }
                    }
                }
                newRow += 1
            } else {
                // Remove all nodes in the completed row from the scene
                for col in 0..<numCols {
                    lockedBlocks[row][col]?.removeFromParent()
                }
                // Increment the number of cleared lines
                clearCount += 1
            }
        }
        // Update the score based on the number of lines cleared
        scoreManager.addLinesCleared(clearCount)

        // Replace the lockedBlocks array with the new, shifted version
        lockedBlocks = newLockedBlocks
        updateScoreDisplay()
    }

// MARK: - Input Handling

    /// Called when a touch begins.
    func touchDown(atPoint pos : CGPoint) {
        // (Not used in this implementation, but provided for extension.)
    }

    /// Called when a touch moves.
    func touchMoved(toPoint pos : CGPoint) {
        // (Not used in this implementation, but provided for extension.)
    }

    /// Called when a touch ends.
    func touchUp(atPoint pos : CGPoint) {
        // (Not used in this implementation, but provided for extension.)
    }

    /// Toggles the pause state of the game and displays or hides the pause menu.
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

    /// Handles tap input:
    /// - Tap tetromino to rotate
    /// - Tap left/right side to move
    /// - Tap pause button or label to pause/resume
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

    private func rotateTetromino() {
        guard let tetromino = activeTetromino else { return }
        let origin = tetromino.origin
        let newOffsets = tetromino.offsets.map { (-$0.1, $0.0) }

        for (dx, dy) in newOffsets {
            let newRow = origin.row + dy
            let newCol = origin.col + dx
            guard newRow >= 0, newRow < numRows, newCol >= 0, newCol < numCols else { return }
            if lockedBlocks[newRow][newCol] != nil { return }
        }

        for (i, (dx, dy)) in newOffsets.enumerated() {
            if let position = gridNodes[origin.row + dy][origin.col + dx]?.position {
                tetromino.blocks[i].position = position
            }
        }
        tetromino.offsets = newOffsets
    }

    /// Called when touches move; delegates to touchMoved.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }

    /// Called when touches end; delegates to touchUp.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    /// Called when touches are cancelled; delegates to touchUp.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

// MARK: - Game Loop

    /// Called once per frame to update game timing and drop the active tetromino if enough time has passed.
    /// Skips updates when the game is paused or the scene has not finished initializing.
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        print("GameScene: update(currentTime:) called")
        if gameplayPaused || basicSquare == nil { return }  // Prevent updates while paused or if not initialized

        if self.lastUpdateTime == 0 {
            self.lastUpdateTime = currentTime
        }

        let dt = currentTime - self.lastUpdateTime

        // Update all GKEntities (if any)
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        // Accumulate time since last automatic fall
        fallTimer += dt
        // Drop the tetromino once enough time has passed
        if fallTimer >= fallInterval {
            fallTimer = 0
            moveTetrominoDown()
        }

        self.lastUpdateTime = currentTime
    }

// MARK: - Pause & Game Over UI

/// Shows the pause menu overlay with a blur effect.
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
/// Returns the interval (seconds) between automatic tetromino falls.
private var fallInterval: TimeInterval {
    // Fallback to 0.5 seconds if UserDefaults value is 0
    return UserDefaults.standard.double(forKey: "FallInterval") == 0 ? 0.5 : UserDefaults.standard.double(forKey: "FallInterval")
}
/// Handles the game over state: pauses the game and displays a "GAME OVER" label.
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

// MARK: - TetrominoType Utilities

extension TetrominoType {
    /// Returns the spawn row offset for the given tetromino type.
    func spawnOffsetRow(numRows: Int) -> Int {
        switch self {
        case .I: return numRows - 4
        case .O: return numRows - 2
        case .T, .L, .J, .S, .Z: return numRows - 3
        }
    }
}

