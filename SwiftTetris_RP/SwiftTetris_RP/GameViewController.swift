//
//  GameViewController.swift
//  SwiftTetris_RP
//
//  Created by Robert Palmer on 4/10/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    private var hasShownSplash = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
        startGameScene()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //startGameScene()
//        if !hasShownSplash {
//                hasShownSplash = true
//
//                let splash = SplashView(frame: view.bounds)
//                view.addSubview(splash)
//
//                splash.startAnimation {
//                    self.startGameScene()
//                }
//            } else {
//                startGameScene()
//        }
    }

    private func startGameScene() {
        if let scene = GKScene(fileNamed: "GameScene") {
            if let sceneNode = scene.rootNode as! GameScene? {
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                sceneNode.scaleMode = .aspectFill

                if let skView = self.view as? SKView {
                    skView.ignoresSiblingOrder = true
                    skView.showsFPS = true
                    skView.showsNodeCount = true
                    skView.presentScene(sceneNode)
                }
            }
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func loadView() {
            // Make the root view an SKView so SpriteKit can render
            self.view = SKView()
        }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
