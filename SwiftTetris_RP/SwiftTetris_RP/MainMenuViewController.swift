//
//  MainMenuViewController.swift
//  SwiftTetris_RP
//
//  Created by Robert Palmer on 4/11/25.
//

import Foundation
import UIKit

/// The main menu screen for SwiftTetris_RP. Displays the title and navigation buttons to start the game or view credits.
class MainMenuViewController: UIViewController {

    /// A bold, centered title label displaying "Tetris".
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tetris"
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = .center
        label.accessibilityIdentifier = "mainMenuTitleLabel"
        label.accessibilityLabel = "Tetris Main Menu"
        return label
    }()

    /// A button that launches the game when tapped.
    lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start Game", for: .normal)
        button.setTitleColor(UIColor.systemIndigo, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.accessibilityIdentifier = "startGameButton"
        button.accessibilityLabel = "Start Game"
        button.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        return button
    }()

    /// A button that presents the credits screen when tapped.
    lazy var creditsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Credits", for: .normal)
        button.setTitleColor(UIColor.systemIndigo, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.accessibilityIdentifier = "creditsButton"
        button.accessibilityLabel = "Show Credits"
        button.addTarget(self, action: #selector(showCredits), for: .touchUpInside)
        return button
    }()

    /// A vertical stack view that arranges the title and buttons with spacing and alignment.
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, startButton, creditsButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 30
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the view and add the stack view to the layout using safe area constraints.
        view.backgroundColor = .white
        view.addSubview(stack)
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: guide.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: guide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: guide.trailingAnchor, constant: -16)
        ])
    }

    /// Presents the main game view controller in full screen mode.
    @objc private func startGame() {
        let gameVC = GameViewController()
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true, completion: nil)
    }

    /// Presents the credits view controller in a modal form sheet.
    @objc private func showCredits() {
        let creditsVC = CreditsViewController()
        creditsVC.modalPresentationStyle = .formSheet
        present(creditsVC, animated: true, completion: nil)
    }
}
  
