//
//  LaunchScreenViewController.swift
//  SwiftTetris_RP
//
//  Created by Robert Palmer on 4/13/25.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit


class LaunchScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Wait 5 seconds, then fade to black
         DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
             self.fadeToBlack()
         }
    }
    
    private func fadeToBlack() {
        let blackView = UIView(frame: self.view.bounds)
        blackView.backgroundColor = .black
        blackView.alpha = 0.0
        self.view.addSubview(blackView)

        UIView.animate(withDuration: 1.5, animations: {
            blackView.alpha = 1.0
        }) {
            _ in
                    // Transition after the fade is complete
            let mainMenuVC = MainMenuViewController()
                    mainMenuVC.modalPresentationStyle = .fullScreen
                    self.present(mainMenuVC, animated: false, completion: nil)
        }
    }
    
    private func setupUI(){
        view.backgroundColor = .white 
        
    }
}
