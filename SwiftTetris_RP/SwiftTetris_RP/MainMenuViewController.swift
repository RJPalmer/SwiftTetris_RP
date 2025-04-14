//
//  MainMenuViewController.swift
//  SwiftTetris_RP
//
//  Created by Robert Palmer on 4/11/25.
//

import Foundation
import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white

        let titleLabel = UILabel()
        titleLabel.text = "Tetris"
        titleLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        titleLabel.textAlignment = .center

        let startButton = UIButton(type: .system)
        startButton.setTitle("Start Game", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)

        let creditsButton = UIButton(type: .system)
        creditsButton.setTitle("Credits", for: .normal)
        creditsButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        creditsButton.addTarget(self, action: #selector(showCredits), for: .touchUpInside)


        let stack = UIStackView(arrangedSubviews: [titleLabel, startButton, creditsButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 30
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    @objc private func startGame() {
        let gameVC = GameViewController()
        gameVC.modalPresentationStyle = .fullScreen
        present(gameVC, animated: true, completion: nil)
    }

    @objc private func showCredits() {
        let creditsVC = CreditsViewController()
        creditsVC.modalPresentationStyle = .formSheet
        present(creditsVC, animated: true, completion: nil)
    }
}
