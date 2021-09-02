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
    @IBOutlet var inputTextField: NSTextField!
    @IBOutlet var button: NSButton!
    @IBOutlet var checkbox: NSButton!
    let queue = DispatchQueue(label: "lonpos_queue")
    
    private func showGame(game: Game) {
        let scnView = SCNView()
        let scene = createScene(scnView: scnView)
        scnView.scene = scene
        let pyramiad = SCNNode()
        for index in 0...54 {
            let p = PointInt3D.point(from: index)
            let char = game.space[index]
            guard let piece = Game.pieceCandidates.first(where: {$0.identifier == char}) else {abort()}
            let ball = SCNSphere(radius: 0.5)
            ball.firstMaterial?.diffuse.contents = piece.color
            let node = SCNNode(geometry: ball)
            let pos = SCNVector3(Float(p.z) / 2 + Float(p.x) - 2, Float(p.z) * sqrtf(2) / 2, Float(p.z) / 2 + Float(p.y) - 2)
            node.position = pos
            pyramiad.addChildNode(node)
            let action = SCNAction.moveBy(x: pos.x, y: pos.y, z: pos.z, duration: 5)
            let a = SCNAction.sequence([action, action.reversed()])
            node.runAction(SCNAction.repeatForever(a))
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
    
    @IBAction func startGame(sender: NSControl) {
        let str = inputTextField.stringValue.uppercased().replacingOccurrences(of: ".", with: " ")
        /*
         "BBFFFBBWSFBWWSFWWYSSYYYYS"
         "UU  SU   SU  SSU  S"
         "FFFY FYYYYF"
         "Y     YX   X,Y    X,YX X,Y"
         "Y     YX   X,Y    X,YX X,Y"
         "B    CBC  CCC,B    B,B"
         */
        do {
            if checkbox.state == .off {
                let game = try Game2d(str)
                button.isEnabled = false
                checkbox.isEnabled = false
                queue.async {
                    game.start()
                }
            } else if checkbox.state == .on {
                let strList = str.split(separator: ",").map {String($0)}
                let game = strList.count > 1 ? try Game(strList) : try Game(str)
                button.isEnabled = false
                view.addSubview(inputTextField, positioned: .below, relativeTo: button)
                queue.async {
                    game.start()
                }
            }
        } catch LonposError.inputError(let msg){
            //show error to user
            let alert = NSAlert()
            alert.messageText = msg
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } catch {
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "lonpos"), object: nil, queue: OperationQueue.main) { note in
            if note.object == nil {
                self.button.isEnabled = true
                self.checkbox.isEnabled = true
            } else if let game = note.object as? Game {
                self.showGame(game: game)
            } else if let game = note.object as? Game2d {
                self.inputTextField.stringValue = self.inputTextField.stringValue + "\n" + game.description
            }
        }
        
//        do {
//            let game = try Game2d("sss.s..s")
//            DispatchQueue.global(qos: .background).async {
//                game.start()
//            }
//        } catch LonposError.inputError(let msg) {
//            print(msg)
//        } catch {
//            print(error)
//        }
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
