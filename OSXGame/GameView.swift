//
//  GameView.swift
//  OSXGame
//
//  Created by Julio César Guzman on 11/21/15.
//  Copyright (c) 2015 Julio. All rights reserved.
//

import SceneKit

class DecalContactDelegate : NSObject, SCNPhysicsContactDelegate {
    
    var decalNode : SCNNode
    var sceneRootNode : SCNNode
    
    init(decalNode:SCNNode, sceneRootNode : SCNNode) {
        self.decalNode = decalNode
        self.sceneRootNode = sceneRootNode
        super.init()
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if nodeA.physicsBody?.categoryBitMask == commonBitMaskToEnableContactDelegate &&
            nodeB.physicsBody?.categoryBitMask == commonBitMaskToEnableContactDelegate {
            if magnitudeOf(nodeA.physicsBody!.velocity) == 0 {
                self.addDamageToNode(nodeA, bullet:nodeB, contact: contact)
            }
            if magnitudeOf(nodeB.physicsBody!.velocity) == 0 {
                self.addDamageToNode(nodeB, bullet:nodeA, contact: contact)
            }
        }
    }
    
    func addDamageToNode(damagedNode : SCNNode, bullet:SCNNode, contact: SCNPhysicsContact) {
        
        let rootNode = self.sceneRootNode
        let decal = rootNode.childNodeWithName("plane", recursively: true)!.clone()
        let gradoDeLibertadDePosicion = SCNNode()
        let gradoDeLibertadDeRotacionRespectoALaNormal = SCNNode()
        let gradoDeLibertadDeRotacionDeAnileacionConLaNormal = SCNNode()
        
        damagedNode.addChildNode(gradoDeLibertadDePosicion)
        gradoDeLibertadDePosicion.addChildNode(gradoDeLibertadDeRotacionDeAnileacionConLaNormal)
        gradoDeLibertadDeRotacionDeAnileacionConLaNormal.addChildNode(gradoDeLibertadDeRotacionRespectoALaNormal)
        gradoDeLibertadDeRotacionRespectoALaNormal.addChildNode(decal)
        
        
        let bulletVelocity = bullet.physicsBody!.velocity
        let contactNormal = contact.contactNormal
        let angulo = atan2(bulletVelocity.x, bulletVelocity.z)
        let normalcruzvelocidad = contactNormal ^ normalize(bulletVelocity)
        let ejeDeRotacion = normalcruzvelocidad
        let vectorEnElPiso = contactNormal ^ ejeDeRotacion
        let vectorArriba = contactNormal
        let anguloDeAlineacionConLaNormal = angleBetween(vectorEnElPiso, vectorB: vectorArriba)

        gradoDeLibertadDePosicion.position = rootNode.convertPosition(contact.contactPoint, toNode: damagedNode)
        gradoDeLibertadDeRotacionRespectoALaNormal.rotation = SCNVector4Make(contactNormal.x, contactNormal.y, contactNormal.z, angulo)
        gradoDeLibertadDeRotacionDeAnileacionConLaNormal.rotation = SCNVector4Make(ejeDeRotacion.x, ejeDeRotacion.y, ejeDeRotacion.z, anguloDeAlineacionConLaNormal)
        
       
        //add random height
        let y = gradoDeLibertadDePosicion.position.y + CGFloat(Random.randomBounded(0.0, max: 1.0))
        gradoDeLibertadDePosicion.position = SCNVector3Make(gradoDeLibertadDePosicion.position.x, y , gradoDeLibertadDePosicion.position.z)
        
    }
}

class InputView: SCNView {
    
    var keyboard = NSMutableDictionary()
    let mouseMovementRelation : CGFloat = 1 / 1000
    var mouseMoveX = CGFloat(0)
    var mouseMoveY = CGFloat(0)
    
    override func keyDown(theEvent: NSEvent) {
        super.keyDown(theEvent)
        self.updateKeyboardState(theEvent.characters, pressed: true)
    }
    
    override func keyUp(theEvent: NSEvent) {
        super.keyUp(theEvent)
        self.updateKeyboardState(theEvent.characters, pressed: false)
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        super.mouseMoved(theEvent)
    
        mouseMoveX += (theEvent.deltaX) * mouseMovementRelation
        mouseMoveY += (theEvent.deltaY) * mouseMovementRelation
    }
    
    override func mouseDown(theEvent: NSEvent) {
        super.mouseDown(theEvent)
    }
    
    func updateKeyboardState(character : String?, pressed:Bool) {
        if (character != nil) {
            keyboard.setObject(NSNumber(bool: pressed), forKey: character!)
        }
    }
    
    func handleKeyStroke (key : String, handler : () -> ()) {
        let keyIsPressedValue = self.keyboard[key] as? NSNumber
        if keyIsPressedValue != nil && keyIsPressedValue!.boolValue {
            handler()
        }
    }
    
}

class GameView: InputView {
    
    var smiley : SCNNode {
        get {
            return self.loadNodeFromScene("smiley")
        }
    }
    
    var camera : SCNNode {
        get {
            return self.loadNodeFromScene("camera")
        }
    }
    
    var weapon : SCNNode {
        get {
            return self.loadNodeFromScene("weapon")
        }
    }
    
    var bullet : SCNNode {
        get {
            return self.loadNodeFromScene("bullet")
        }
    }
    
    override func mouseMoved(theEvent: NSEvent) {
        super.mouseMoved(theEvent)
        self.performRotation()
    }
    
    override func keyDown(theEvent: NSEvent) {
        super.keyDown(theEvent)
        self.handleKeyStroke("p") { () -> () in
            self.shoot()
        }
    }
    
    func shoot() {
        let weapon = self.weapon
        let bullet = self.bullet
      
        let force : CGFloat = 500
        
        let pointA = weapon.convertPosition(SCNVector3Make(0.0, 0.0, 1.0), toNode: self.scene!.rootNode)
        let pointB = weapon.convertPosition(SCNVector3Zero, toNode: self.scene!.rootNode)
        let directionalVector = pointA - pointB
        let forceVector = SCNVector3Make(directionalVector.x * force, directionalVector.y * force, directionalVector.z * force)
        
        bullet.physicsBody?.velocity = SCNVector3Zero
        bullet.physicsBody?.angularVelocity = SCNVector4Zero;
        bullet.physicsBody?.affectedByGravity = false
        bullet.position = pointB
        bullet.physicsBody?.applyForce(forceVector, impulse: true)
        
        self.scene?.rootNode.addChildNode(bullet)
    }
    
    func performRotation () {
        let α = -self.mouseMoveX
        let ß = -self.mouseMoveY
        
        smiley.rotation = SCNVector4Make(0.0, 1.0, 0.0, α)
        camera.rotation = SCNVector4Make(1.0, 0.0, 0.0, ß)
    }
    
    func performOnUpdate () {
        self.handleKeyStrokes()
    }
    
    func handleKeyStrokes () {
        let speed = CGFloat(0.5)
        let pi = CGFloat(π)
        let smiley = self.smiley
        let camera = self.camera
        let θ : CGFloat = smiley.rotation.w
        
        self.handleKeyStroke("w") { () -> () in
            smiley.position.x = smiley.position.x + sin(θ) * speed
            smiley.position.z = smiley.position.z + cos(θ) * speed
        }
        self.handleKeyStroke("s") { () -> () in
            smiley.position.x = smiley.position.x + sin(θ + pi) * speed
            smiley.position.z = smiley.position.z + cos(θ + pi) * speed
        }
        self.handleKeyStroke("a") { () -> () in
            smiley.position.x = smiley.position.x + sin(θ + pi / 2) * speed
            smiley.position.z = smiley.position.z + cos(θ + pi / 2) * speed
        }
        self.handleKeyStroke("d") { () -> () in
            smiley.position.x = smiley.position.x + sin(θ - pi / 2) * speed
            smiley.position.z = smiley.position.z + cos(θ - pi / 2) * speed
        }
        
        self.handleKeyStroke("e") { () -> () in
            camera.camera?.xFov++
            camera.camera?.yFov++
        }
        self.handleKeyStroke("q") { () -> () in
            camera.camera?.xFov--
            camera.camera?.yFov--
        }
    }
    
    func loadNodeFromScene(name:String) -> SCNNode {
        return (self.scene?.rootNode.childNodeWithName(name , recursively: true))!
    }
}
