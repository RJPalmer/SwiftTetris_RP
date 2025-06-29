//
//  CreditsViewController.swift
//  SwiftTetris_RP
//
//  Created by Robert Palmer on 4/11/25.
//
import Foundation
import UIKit

class CreditsViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let creditLabel = UILabel()
        creditLabel.text = "SwiftTetris_RP\nCreated by Robert Palmer"
        creditLabel.numberOfLines = 0
        creditLabel.textAlignment = .center
        creditLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        creditLabel.translatesAutoresizingMaskIntoConstraints = false

        let dismissButton = UIButton(type: .system)
        dismissButton.setTitle("Back to Main Menu", for: .normal)
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        dismissButton.addTarget(self, action: #selector(dismissCredits), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(creditLabel)
        view.addSubview(dismissButton)

        NSLayoutConstraint.activate([
            creditLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            creditLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            dismissButton.topAnchor.constraint(equalTo: creditLabel.bottomAnchor, constant: 20),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func dismissCredits() {
        dismiss(animated: true, completion: nil)
    }
}
