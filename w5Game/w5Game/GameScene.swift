/\
import SpriteKit
import GameplayKit

//  - add Physics categories struct
struct PhysicsCategory{
    static let None : UInt32 = 0
    static let All : UInt32 = UInt32.max
    static let Baddy : UInt32 = 0b1 // 1
    static let Hero : UInt32 = 0b10 // 2
    // future expansion - dunno if we'll make it here
    static let Projectile : UInt32 = 0b11 // 3
}

// add collision detection delegate
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    // define our sport ninja
    private var sportNode : SKSpriteNode?
    
    // add score
    private var score : Int?
    let scoreIncrement = 10
    private var lblScore : SKLabelNode?
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        //  - initialize our hero node - the jays
        sportNode = SKSpriteNode(imageNamed: "jays.jpg")
       // sportNode?.position = CGPoint(x: size.height*0.1, y: size.width*0.5)
         sportNode?.position = CGPoint(x: 10, y: 10)

        addChild(sportNode!)
       
        
        // - add physics to our hero
        physicsWorld.gravity = CGVector(dx: 0,dy: 0)
        physicsWorld.contactDelegate = self
        //
        
        // add collision detection to our hero
        sportNode?.physicsBody = SKPhysicsBody(circleOfRadius: (sportNode?.size.width)!/2)
        sportNode?.physicsBody?.isDynamic = true
        sportNode?.physicsBody?.categoryBitMask = PhysicsCategory.Hero
        sportNode?.physicsBody?.contactTestBitMask = PhysicsCategory.Baddy
        sportNode?.physicsBody?.collisionBitMask = PhysicsCategory.None
        sportNode?.physicsBody?.usesPreciseCollisionDetection = true
        
        
        // bringing in the baddies
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addBaddy), SKAction.wait(forDuration: 1.0)])))

        // init score
        score = 0
        self.lblScore = self.childNode(withName: "//score") as? SKLabelNode
        self.lblScore?.text = "Score: \(score)"
        if let slabel = self.lblScore {
            slabel.alpha = 0.0
            slabel.run(SKAction.fadeIn(withDuration: 2.0))
        }

    }
    
    // adding bad guy leafs
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min:CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max-min) + min
    }
    
    func addBaddy(){
        
        let baddy = SKSpriteNode(imageNamed: "leafs.png")
        
        let actualY = random(min: baddy.size.height/2, max: size.height-baddy.size.height/2)
        
        baddy.position = CGPoint(x: size.width + baddy.size.width/2, y:actualY)
        
        addChild(baddy)
        
        // dd physics to our baddy
        baddy.physicsBody = SKPhysicsBody(rectangleOf: baddy.size)
        baddy.physicsBody?.isDynamic = true
        baddy.physicsBody?.categoryBitMask = PhysicsCategory.Baddy
        baddy.physicsBody?.contactTestBitMask = PhysicsCategory.Hero
        baddy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
       
        let actualDuration = random(min: CGFloat(2.0), max:CGFloat(4.0))
        
        let actionMove = SKAction.move(to: CGPoint(x: -baddy.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        baddy.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    // delegete methods for physics
        // heroDidCollideWithBaddy()
        // didBegin()
    
    func heroDidCollideWithBaddy(hero: SKSpriteNode, baddy: SKSpriteNode){
        print("hit")
        
        //  update score
        score = score! + scoreIncrement
        self.lblScore?.text = "Score: \(score)"
        if let slabel = self.lblScore {
            slabel.alpha = 0.0
            slabel.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // need to come up with something
        // maybe have baddy grow?
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }else{
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if((firstBody.categoryBitMask & PhysicsCategory.Baddy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Hero != 0)){
            heroDidCollideWithBaddy(hero: firstBody.node as! SKSpriteNode, baddy: secondBody.node as! SKSpriteNode)
        }
    }
  
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
            
            // now lets move our hero
            let actionMove = SKAction.move(to: pos, duration: TimeInterval(2.0))
            
            let actionMoveDone = SKAction.rotate(byAngle: CGFloat(360.0), duration: 1.0)
            sportNode?.run(SKAction.sequence([actionMove, actionMoveDone]))
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
