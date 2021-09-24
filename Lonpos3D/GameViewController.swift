//
//  GameViewController.swift
//  Lonpos3D
//
//  Created by Wei Dong on 2021-08-22.
//

import SceneKit
import SpriteKit
import QuartzCore

class GameViewController: NSViewController {
    private var sceneList = [] as [SCNView]
    @IBOutlet var inputTextField: NSTextView!
    @IBOutlet var button: NSButton!
    @IBOutlet var comboBox: NSComboBox!
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
    
    @IBAction func startGame(sender: NSControl) {
        let str = inputTextField.string
        /*
         "BBFFFBBWSFBWWSFWWYSSYYYYS"
         "UU  SU   SU  SSU  S"
         "FFFY FYYYYF"
         "Y     YX   X,Y    X,YX X,Y"
         "Y     YX   X,Y    X,YX X,Y"
         "B    CBC  CCC,B    B,B"
         */
        do {
            switch comboBox.stringValue {
            case "Lonpos 2D":
                UserDefaults.standard.setValue(2, forKey: "last_game_type")
                let game = try Game2d(str.uppercased().replacingOccurrences(of: ".", with: " "))
                button.isEnabled = false
                UserDefaults.standard.setValue(str, forKey: "last_input")
                queue.async {
                    game.start()
                }
            case "Lonpos 3D":
                UserDefaults.standard.setValue(1, forKey: "last_game_type")
                let strList = str.uppercased().replacingOccurrences(of: ".", with: " ").split(separator: ",", omittingEmptySubsequences: false).map {String($0)}
                let game = strList.count > 1 ? try Game3d(strList) : try Game3d(str.uppercased().replacingOccurrences(of: ".", with: " "))
                button.isEnabled = false
                UserDefaults.standard.setValue(str, forKey: "last_input")
                queue.async {
                    game.start()
                }
            case "Klotski":
                UserDefaults.standard.setValue(3, forKey: "last_game_type")
                let game = Klotski(str.replacingOccurrences(of: ".", with: " "))
                UserDefaults.standard.setValue(str, forKey: "last_input")
                queue.async {
                    game.start()
                }
            case "Woodoku":
                UserDefaults.standard.setValue(4, forKey: "last_game_type")
                showWoodoku()
            default:
                GameViewController.showAlert(message: "Please select a game type")
            }
        } catch LonposError.inputError(let msg){
            GameViewController.showAlert(message: msg)
        } catch {
            print(error)
        }
        UserDefaults.standard.synchronize()
    }
    
    fileprivate static func showAlert(message: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func showWoodoku() {
        inputTextField.isHidden = true
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        let scene = MySKScene(size: view.bounds.size)
        
        skView.presentScene(scene)
        skView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(skView)
        NSLayoutConstraint.activate([
            skView.leftAnchor.constraint(equalTo: view.leftAnchor),
            skView.rightAnchor.constraint(equalTo: view.rightAnchor),
            skView.topAnchor.constraint(equalTo: view.topAnchor),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let input = UserDefaults.standard.string(forKey: "last_input") {
            inputTextField.string = input
        }
        let type = UserDefaults.standard.integer(forKey: "last_game_type")
        switch type {
        case 1:
            comboBox.stringValue = "Lonpos 3D"
        case 2:
            comboBox.stringValue = "Lonpos 2D"
        case 3:
            comboBox.stringValue = "Klotski"
        case 4:
            comboBox.stringValue = "Woodoku"
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
                var str = ""
                for step in g.steps {
                    str += step.description + " | "
                }
                self.inputTextField.string = str
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

class MySKScene: SKScene {
    private var game: Woodoku
    private let radius: Double = 25
    private let smallRadius = 5 as Double
    private var isCalculating = false
    private var selectedPieces: [Woodoku.Piece] = []
    
    override init(size: CGSize) {
        if let list = UserDefaults.standard.object(forKey: "Woodoku") as? [[Bool]] {
            game = Woodoku(board: list)
        } else {
            game = Woodoku()
        }
        super.init(size: size)
        
        scaleMode = .resizeFill
        let root = SKNode()
        //draw board
        for x in 0...8 {
            for y in 0...8 {
                let node = SKShapeNode(circleOfRadius: radius)
                node.position = CGPoint(x: Double(x) * radius * 2 + radius, y: Double(8 - y) * radius * 2 + radius)
                node.fillColor = game.board[y][x] ? .red : .clear
                node.strokeColor = NSColor(white: 0.4, alpha: 1)
                node.name = "\(x),\(y)" + (game.board[y][x] ? "red" : "")
                root.addChild(node)
            }
        }
        //draw pieces
        var yoffset = smallRadius
        var xoffset = radius * 2 * 10
        for type in Woodoku.PieceType.allCases {
            let piece = type.piece
            let node = createNode(for: piece)
            node.name = "piece:" + type.rawValue
            self.addChild(node)
            node.position = CGPoint(x: xoffset, y: yoffset)
            yoffset += smallRadius * 2 * Double(piece.pattern.count + 1)
            if yoffset >= radius * 2 * 9 {
                yoffset = smallRadius
                xoffset += radius * 3
            }
        }
        
        addChild(root)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createNode(for piece: Woodoku.Piece) -> SKNode {
        let node = SKNode()
        for y in 0..<piece.pattern.count {
            for x in 0..<piece.pattern[y].count where piece.pattern[y][x] {
                let ball = SKShapeNode(circleOfRadius: smallRadius)
                ball.fillColor = .yellow
                ball.strokeColor = .black
                ball.position = CGPoint(x: Double(x) * smallRadius * 2, y: Double(piece.pattern.count - 1 - y) * smallRadius * 2)
                node.addChild(ball)
            }
        }
        return node
    }
    
    private func updateBoard() {
        for x in 0...8 {
            for y in 0...8 {
                guard let node = (childNode(withName: "//\(x),\(y)") ?? childNode(withName: "//\(x),\(y)red")) as? SKShapeNode else {
                    print("cannot find node with name begins with \(x),\(y)")
                    abort()
                }
                node.fillColor = game.board[y][x] ? .red : .clear
                node.name = "\(x),\(y)" + (game.board[y][x] ? "red" : "")
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        guard !isCalculating else {return}
        var node = atPoint(event.location(in: self))
        if node.name == nil, let parent = node.parent {
            node = parent
        }
        guard let name = node.name, name.count >= 3 else {return}
        guard let snode = node as? SKShapeNode else {
            if let name = node.name, name.hasPrefix("piece:") {
                let rawValue = name[name.index(name.startIndex, offsetBy: 6)...]
                if let pieceType = Woodoku.PieceType(rawValue: String(rawValue)) {
                    let piece = pieceType.piece
                    let node = createNode(for: piece)
                    node.name = "selected"
                    node.position = CGPoint(x: Double(1 + selectedPieces.count * 5) * 2 * smallRadius, y: 9 * radius * 2 + radius)
                    addChild(node)
                    selectedPieces.append(piece)
                }
                
                if selectedPieces.count == 3 {
                    calculate()
                }
            }
            return
        }
        
        let charArray = Array(name)
        guard let x = Int(String(charArray[0])), let y = Int(String(charArray[2])) else {return}
        
        if name.hasSuffix("red") {
            snode.fillColor = .clear
            game.board[y][x] = false
            var newName = name
            newName.removeLast(3)
            snode.name = newName
        } else {
            snode.fillColor = .red
            game.board[y][x] = true
            snode.name = (snode.name ?? "") + "red"
        }
        saveGame()
    }
    
    private func showSteps(bestPiecePositions: [Woodoku.PieceWithPosition], colorValue: CGFloat) {
        guard let piecePosition = bestPiecePositions.first else {
            //remove selected pieces
            self.enumerateChildNodes(withName: "selected") { node, _ in
                node.removeFromParent()
            }
            saveGame()
            return
        }
        let piece = piecePosition.piece
        let pos = piecePosition.pos
        for y in 0..<piece.pattern.count {
            for x in 0..<piece.pattern[y].count where piece.pattern[y][x] {
                guard let node = self.childNode(withName: "//\(x + pos.x),\(y + pos.y)") as? SKShapeNode else {
                    print("cannot find node with name begins with \(x + pos.x),\(y + pos.y)")
                    abort()
                }
                node.fillColor = NSColor(hue: colorValue, saturation: 1, brightness: 1, alpha: 1)
            }
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.showTrimmedBoardWithAnimation(pieceWithPlace: piecePosition)
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                GameViewController.showAlert(message: "Next")
                self.showSteps(bestPiecePositions: Array(bestPiecePositions.dropFirst()), colorValue: 0.2 + colorValue)
            }
        }
    }
    
    private func saveGame() {
        UserDefaults.standard.set(game.board, forKey: "Woodoku")
        UserDefaults.standard.synchronize()
    }
    
    private func showTrimmedBoardWithAnimation(pieceWithPlace: Woodoku.PieceWithPosition) {
        let unTrimmedGame = game
        if let g = game.place(piece: pieceWithPlace.piece, at: pieceWithPlace.pos) {
            game = g
        } else {
            abort()
        }
        game.trim()
        for x in 0...8 {
            for y in 0...8 {
                if unTrimmedGame.board[y][x] && !game.board[y][x] {
                    guard let node = childNode(withName: "//\(x),\(y)*") as? SKShapeNode else {
                        print("cannot find node with name begins with \(x),\(y)")
                        abort()
                    }
                    node.run(node.getFillColorFadeOutAction())
                }
            }
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
            self.updateBoard()
        }
    }
    
    private func calculate() {
        isCalculating = true
        DispatchQueue.global(qos: .background).async {
            if let bestPiecePositions = self.game.place(pieces: self.selectedPieces) {
                DispatchQueue.main.async {
                    self.isCalculating = false
                    self.selectedPieces.removeAll()
//                    self.response(to: bestPiecePositions)
                    self.showSteps(bestPiecePositions: bestPiecePositions, colorValue: 0.2)
                }
            }
        }
    }
}

extension SKShapeNode {
    func getFillColorFadeOutAction() -> SKAction {
        func lerp(_ a: Double, _ b: Double, _ fraction: Double) -> Double {
            return (b-a) * fraction + a
        }

        // get the Color components of col1 and col2
        var r:CGFloat = 0.0, g:CGFloat = 0.0, b:CGFloat = 0.0, a1:CGFloat = 0.0;
        fillColor.getRed(&r, green: &g, blue: &b, alpha: &a1)
        let a2:CGFloat = 0.0;

        // return a color fading on the fill color
        let timeToRun: CGFloat = 0.3;
        
        let action = SKAction.customAction(withDuration: 0.3) { node, elapsedTime in
            let fraction = elapsedTime / timeToRun
            let col3 = SKColor(red: r, green: g, blue: b, alpha: lerp(a1,a2,fraction))
            (node as? SKShapeNode)?.fillColor = col3
        }

        return action
    }
}
