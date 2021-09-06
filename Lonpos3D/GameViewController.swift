//
//  GameViewController.swift
//  Lonpos3D
//
//  Created by Wei Dong on 2021-08-22.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {
    private var sceneList = [] as [SCNView]
    @IBOutlet var inputTextField: NSTextView!
    @IBOutlet var button: NSButton!
    @IBOutlet var btnLonpos3d: NSButton!
    @IBOutlet var btnLonpos2d: NSButton!
    @IBOutlet var btnKlotski: NSButton!
    let queue = DispatchQueue(label: "lonpos_queue")
    
    private func showGame(game: IGame) {
        guard sceneList.count < 18 else {return}
        let scnView = SCNView()
        let scene = createScene(scnView: scnView)
        scnView.scene = scene
        let pyramiad = SCNNode()
        for index in 0...54 {
            let p = game.point3d(from: index)
            let char = game.space[index]
            guard let piece = Game.pieceCandidates.first(where: {$0.identifier == char}) else {abort()}
            let ball = SCNSphere(radius: 0.5)
            ball.firstMaterial?.diffuse.contents = piece.color
            let node = SCNNode(geometry: ball)
            let pos = SCNVector3(Float(p.z) / 2 + Float(p.x) - 2, Float(p.z) * sqrtf(2) / 2, Float(p.z) / 2 + Float(p.y) - 2)
            node.position = pos
            pyramiad.addChildNode(node)
//            let action = SCNAction.moveBy(x: pos.x, y: pos.y, z: pos.z, duration: 5)
//            let a = SCNAction.sequence([action, action.reversed()])
//            node.runAction(SCNAction.repeatForever(a))
        }
        
        scene.rootNode.addChildNode(pyramiad)
//        pyramiad.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 3)))
        
        sceneList.forEach {$0.removeFromSuperview()}
        scnView.translatesAutoresizingMaskIntoConstraints = false
        sceneList.append(scnView)
        sceneList.forEach {self.view.addSubview($0)}
        var constraints = [NSLayoutConstraint]()
        var lastSceneView: SCNView?
        let cols = sceneList.count >= 6 ? 6 : sceneList.count
        let rows = sceneList.count <= cols ? 1 : CGFloat(ceilf(Float(sceneList.count) / Float(cols)))
        for i in 0..<sceneList.count {
            let v = sceneList[i]
            if i % cols == 0 {
                lastSceneView = nil
            }
            if let lastView = lastSceneView {
                constraints.append(v.leftAnchor.constraint(equalTo: lastView.rightAnchor))
                lastSceneView = v
            } else {
                constraints.append(v.leftAnchor.constraint(equalTo: self.view.leftAnchor))
                lastSceneView = v
            }
            constraints.append(v.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1 / CGFloat(cols)))
            if i / cols > 0 {
                constraints.append(v.topAnchor.constraint(equalTo: sceneList[i - cols].bottomAnchor))
            } else {
                constraints.append(v.topAnchor.constraint(equalTo: self.view.topAnchor))
            }
            constraints.append(v.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1 / rows))
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    private func createScene(scnView: SCNView) -> SCNScene {
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 5)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 8)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        var gestureRecognizers = scnView.gestureRecognizers
        gestureRecognizers.insert(clickGesture, at: 0)
        scnView.gestureRecognizers = gestureRecognizers
        
        return scene
    }
    
    @IBAction func radioButtonTyped(button: NSButton) {
        print(button.title)
    }
    
    @IBAction func startGame(sender: NSControl) {
        let str = inputTextField.string
        UserDefaults.standard.setValue(str, forKey: "last_input")
        /*
         "BBFFFBBWSFBWWSFWWYSSYYYYS"
         "UU  SU   SU  SSU  S"
         "FFFY FYYYYF"
         "Y     YX   X,Y    X,YX X,Y"
         "Y     YX   X,Y    X,YX X,Y"
         "B    CBC  CCC,B    B,B"
         */
        do {
            if btnLonpos2d.state == .on {
                UserDefaults.standard.setValue(2, forKey: "last_game_type")
                let game = try Game2d(str.uppercased().replacingOccurrences(of: ".", with: " "))
                button.isEnabled = false
                queue.async {
                    game.start()
                }
            } else if btnLonpos3d.state == .on {
                UserDefaults.standard.setValue(1, forKey: "last_game_type")
                let strList = str.uppercased().replacingOccurrences(of: ".", with: " ").split(separator: ",", omittingEmptySubsequences: false).map {String($0)}
                let game = strList.count > 1 ? try Game3d(strList) : try Game3d(str.uppercased().replacingOccurrences(of: ".", with: " "))
                button.isEnabled = false
                queue.async {
                    game.start()
                }
            } else if btnKlotski.state == .on {
                UserDefaults.standard.setValue(3, forKey: "last_game_type")
                let game = Klotski(str.replacingOccurrences(of: ".", with: " "))
                queue.async {
                    game.start()
                }
            } else {
                showAlert(message: "Please select a game type")
            }
        } catch LonposError.inputError(let msg){
            showAlert(message: msg)
        } catch {
            print(error)
        }
        UserDefaults.standard.synchronize()
    }
    
    private func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let input = UserDefaults.standard.string(forKey: "last_input") {
            inputTextField.string = input
        }
        let type = UserDefaults.standard.integer(forKey: "last_game_type")
        switch type {
        case 1:
            btnLonpos3d.state = .on
        case 2:
            btnLonpos2d.state = .on
        case 3:
            btnKlotski.state = .on
        default:
            break
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "lonpos"), object: nil, queue: OperationQueue.main) { note in
            guard let game = note.object else {
                self.button.isEnabled = true
                return
            }
            switch game {
            case let g as IGame:
                self.showGame(game: g)
            case let g as Klotski:
                self.inputTextField.string = g.steps.description
            default:
                break
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        if let size = view.window?.frame.size {
            if size.width < 100 || size.height < 100 {
                view.window?.setContentSize(NSSize(width: 640, height: 480))
            }
        }
    }
    
    @objc
    func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        // retrieve the SCNView
        guard let scnView = gestureRecognizer.view as? SCNView else {return}
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = NSColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = NSColor.red
            
            SCNTransaction.commit()
        }
    }
}
