//
//  Tetromino.swift
//  SwiftTetris_RP
//
//  Created by Robert Palmer on 7/1/25.
//

import SpriteKit

enum TetrominoType: CaseIterable {
    case I, O, T, L, J, S, Z

    var blocks: [(Int, Int)] {
        switch self {
        case .I: return [(0,0), (0,1), (0,2), (0,3)]
        case .O: return [(0,0), (1,0), (0,1), (1,1)]
        case .T: return [(0,0), (-1,1), (0,1), (1,1)]
        case .L: return [(0,0), (0,1), (0,2), (1,2)]
        case .J: return [(0,0), (0,1), (0,2), (-1,2)]
        case .S: return [(0,0), (1,0), (0,1), (-1,1)]
        case .Z: return [(0,0), (-1,0), (0,1), (1,1)]
        }
    }

    var color: SKColor {
        switch self {
        case .I: return .cyan
        case .O: return .yellow
        case .T: return .magenta
        case .L: return .orange
        case .J: return .blue
        case .S: return .green
        case .Z: return .red
        }
    }
}

class Tetromino {
    let type: TetrominoType
    var blocks: [SKShapeNode] = []
    var origin: (row: Int, col: Int)
    var offsets: [(Int, Int)]

    init(type: TetrominoType, origin: (row: Int, col: Int), grid: [[SKSpriteNode?]], container: SKNode) {
        self.type = type
        self.origin = origin
        self.offsets = type.blocks

        for (dx, dy) in type.blocks {
            let row = origin.row + dy
            let col = origin.col + dx
            guard row < grid.count, col >= 0, col < grid[0].count,
                  let baseBlock = grid[row][col] else { continue }

            let blockSize = baseBlock.size
            let shape = SKShapeNode(rectOf: blockSize)
            shape.fillColor = type.color
            shape.strokeColor = .black
            shape.lineWidth = 1
            shape.position = baseBlock.position
            shape.zPosition = 10
            container.addChild(shape)
            blocks.append(shape)
        }
    }

    func moveDown(by amount: CGFloat) {
        origin.row -= 1
        for block in blocks {
            block.position.y -= amount
        }
    }

    func moveHorizontally(by offset: Int, cellWidth: CGFloat, numCols: Int) {
        let newCol = origin.col + offset
        for (dx, _) in offsets {
            let targetCol = newCol + dx
            if targetCol < 0 || targetCol >= numCols {
                return
            }
        }
        origin.col = newCol
        for block in blocks {
            block.position.x += CGFloat(offset) * cellWidth
        }
    }

    func remove(from parent: SKNode) {
        blocks.forEach { $0.removeFromParent() }
        blocks.removeAll()
    }
}
 
