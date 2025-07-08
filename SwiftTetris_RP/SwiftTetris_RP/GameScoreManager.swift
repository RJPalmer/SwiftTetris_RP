//
//  GameScoreManager.swift
//  SwiftTetris_RP
//
//  Created by Robert Palmer on 7/6/25.
//


// --- GameScoreManager ---
class GameScoreManager {
    private(set) var score: Int = 0
    private(set) var linesCleared: Int = 0

    func addTetrominoLanding() {
        score += 10
    }

    func addLinesCleared(_ count: Int) {
        guard count > 0 else { return }
        score += 20 * count
        linesCleared += count

        if linesCleared % 4 == 0 {
            let bonusMultiplier = linesCleared / 4
            score += 80 * bonusMultiplier
        }
    }

    func reset() {
        score = 0
        linesCleared = 0
    }
}
