//
//  Game.swift
//  Game
//
//  Created by Julio César Guzman on 12/26/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit
import AVFoundation

class Game: NSObject {

    private weak var model : GameModel!

    init(model : GameModel, scene: SCNScene, pointOfView: SCNNode) {
        super.init()
        self.model = model
        self.scene = scene
        self.pointOfView = pointOfView
        model.addDelegates([self])
        setupAfterSceneAndPointOfViewHaveBeenSet()
    }
    
    // MARK: Scene
    
    private weak var scene : SCNScene!
    private weak var pointOfView : SCNNode!
    
    func setupAfterSceneAndPointOfViewHaveBeenSet() {
        setupAutomaticCameraPositions()
        
        cameraManipulator = CameraManipulator(pointOfView: pointOfView, scene: scene, cameraModel: cameraModel)
        
        setupSounds()
        setupNodes()
        initializeCollectFlowerParticleSystem()
        initializeConfettiParticleSystem()
        putCharacterNodeOnStartingPoint()
        setupPhysicsContactDelegate()
    }
    
    // MARK: Physics contact delegate
    
    private var physicsContactDelegate : PhysicsContactDelegate!
    
    private func setupPhysicsContactDelegate() {
        physicsContactDelegate = PhysicsContactDelegate(game: self)
        scene.physicsWorld.contactDelegate = physicsContactDelegate
    }
    
    // MARK: Sounds
    
    private let musicFileName = "music.m4a"
    private let windSoundFileName = "wind.m4a"
    private let flameThrowerSoundFileName = "flamethrower.mp3"
    private let collectPearlSoundFileName = "collect1.mp3"
    private let collectFlowerSoundFileName = "collect2.mp3"
    private let victoryMusicFileName = "Music_victory.mp3"

    private func setupSounds() {
        let node = scene!.rootNode
        setupMusicOnNode(node)
        setupWindSoundOnNode(node)
        setupFlameThrowerSoundOnNode(node)
        setupCollectPearlSound()
        setupCollectFlowerSound()
        setupVictoryMusic()
    }
    
    private func setupMusicOnNode(node:SCNNode) {
        node.addAudioPlayer(SCNAudioPlayer(source: SCNAudioSource(name: musicFileName, volume: 0.25, positional: false, loops: true, shouldStream: true)))
    }
    
    private func setupWindSoundOnNode(node: SCNNode) {
        node.addAudioPlayer(SCNAudioPlayer(source: SCNAudioSource(name: windSoundFileName, volume: 0.3, positional: false, loops: true, shouldStream: true)))
    }
    
    private var flameThrowerSound: SCNAudioPlayer!
    
    private func setupFlameThrowerSoundOnNode(node : SCNNode) {
        flameThrowerSound = SCNAudioPlayer(source: SCNAudioSource(name: flameThrowerSoundFileName, volume: 0, positional: false, loops: true))
        node.addAudioPlayer(flameThrowerSound)
    }
    
    private var collectPearlSound: SCNAudioSource!
    
    private func setupCollectPearlSound() {
        collectPearlSound = SCNAudioSource(name: collectPearlSoundFileName, volume: 0.5)
    }
    
    private var collectFlowerSound: SCNAudioSource!
    
    private func setupCollectFlowerSound() {
        collectFlowerSound = SCNAudioSource(name: collectFlowerSoundFileName)
    }
    
    private var victoryMusic: SCNAudioSource!
    
    private func setupVictoryMusic() {
         victoryMusic = SCNAudioSource(name: victoryMusicFileName, volume: 0.5, shouldLoad: false)
    }
    
    // MARK: Camera
    
    private var cameraModel = CameraModel()
    private var cameraManipulator : CameraManipulator!
    
    private var currentGround: SCNNode!
    private var mainGround: SCNNode!
    private var groundToCameraPosition = [SCNNode: SCNVector3]()
    
    private func setupAutomaticCameraPositions() {
        let rootNode = scene.rootNode
        
        mainGround = rootNode.childNodeWithName("bloc05_collisionMesh_02", recursively: true)
        
        groundToCameraPosition[rootNode.childNodeWithName("bloc04_collisionMesh_02", recursively: true)!] = SCNVector3(-0.188683, 4.719608, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc03_collisionMesh", recursively: true)!] = SCNVector3(-0.435909, 6.297167, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc07_collisionMesh", recursively: true)!] = SCNVector3( -0.333663, 7.868592, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc08_collisionMesh", recursively: true)!] = SCNVector3(-0.575011, 8.739003, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc06_collisionMesh", recursively: true)!] = SCNVector3( -1.095519, 9.425292, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc05_collisionMesh_02", recursively: true)!] = SCNVector3(-0.072051, 8.202264, 0.0)
        groundToCameraPosition[rootNode.childNodeWithName("bloc05_collisionMesh_01", recursively: true)!] = SCNVector3(-0.072051, 8.202264, 0.0)
    }
    
    private func updateCameraWithCurrentGround(groundNode: SCNNode) {
        if model.isWin() {
            return
        }
        
        if currentGround == nil {
            currentGround = groundNode
            return
        }
        
        let characterNode = foxCharacter.node
        updateThePositionOfTheCameraWhenWeMoveToAnotherBlock(characterNode, groundNode: groundNode)
    }
    
    func updateThePositionOfTheCameraWhenWeMoveToAnotherBlock(characterNode : SCNNode, groundNode: SCNNode) {
        if groundNode != currentGround {
            currentGround = groundNode
            
            if var position = groundToCameraPosition[groundNode] {
                if groundNode == mainGround && characterNode.position.x < 2.5 {
                    position = SCNVector3(-0.098175, 3.926991, 0.0)
                }
                
                let actionY = SCNAction.rotateToX(0, y: CGFloat(position.y), z: 0, duration: 3.0, shortestUnitArc: true)
                actionY.timingMode = SCNActionTimingMode.EaseInEaseOut
                
                let actionX = SCNAction.rotateToX(CGFloat(position.x), y: 0, z: 0, duration: 3.0, shortestUnitArc: true)
                actionX.timingMode = SCNActionTimingMode.EaseInEaseOut
                
                cameraManipulator.cameraYHandle.runAction(actionY)
                cameraManipulator.cameraXHandle.runAction(actionX)
            }
        }
    }
    
    func panCamera(direction : float2) {
        cameraManipulator.panCamera(direction)
    }
    
    // MARK: Character
    
    let foxCharacter = FoxCharacter()
    
    private func putCharacterNodeOnStartingPoint() {
        scene.rootNode.addChildNode(foxCharacter.node)
        let startPosition = scene.rootNode.childNodeWithName("startingPoint", recursively: true)!
        foxCharacter.node.transform = startPosition.transform
    }
    
    func characterDirection(controllerDirection : float2) -> float3 {
        
        var direction = float3(controllerDirection.x, 0.0, controllerDirection.y)
        
        if let pov = pointOfView {
            let p1 = pov.presentationNode.convertPosition(SCNVector3(direction), toNode: nil)
            let p0 = pov.presentationNode.convertPosition(SCNVector3Zero, toNode: nil)
            direction = float3(Float(p1.x - p0.x), 0.0, Float(p1.z - p0.z))
            
            if direction.x != 0.0 || direction.z != 0.0 {
                direction = normalize(direction)
            }
        }
        
        return direction
    }
    
    func characterNode(characterNode: SCNNode, hitWall wall: SCNNode, withContact contact: SCNPhysicsContact) {
        if characterNode.parentNode != foxCharacter.node {
            return
        }
        
        if foxCharacter.maxPenetrationDistance > contact.penetrationDistance {
            return
        }
        
        foxCharacter.maxPenetrationDistance = contact.penetrationDistance
        
        var characterPosition = float3(foxCharacter.node.position)
        var positionOffset = float3(contact.contactNormal) * Float(contact.penetrationDistance)
        positionOffset.y = 0
        characterPosition += positionOffset
        
        foxCharacter.replacementPosition = SCNVector3(characterPosition)
    }
    
    // MARK: Setup nodes
    
    private var flames = [SCNNode]()
    private var enemies = [SCNNode]()
    
    private var grassArea: SCNMaterial!
    private var waterArea: SCNMaterial!
    
    private func setupNodes() {
        // Retrieve various game elements in one traversal
        var collisionNodes = [SCNNode]()
        scene.rootNode.enumerateChildNodesUsingBlock { (node, _) in
            switch node.name {
            case .Some("flame"):
                node.physicsBody!.categoryBitMask = BitmaskEnemy
                self.flames.append(node)
            case .Some("enemy"):
                self.enemies.append(node)
            case let .Some(s) where s.rangeOfString("collision") != nil:
                collisionNodes.append(node)
            default:
                break
            }
        }
        
        for node in collisionNodes {
            node.hidden = false
            setupCollisionNode(node)
        }
    }
    
    private func setupCollisionNode(node: SCNNode) {
        if let geometry = node.geometry {
            // Collision meshes must use a concave shape for intersection correctness.
            node.physicsBody = SCNPhysicsBody.staticBody()
            node.physicsBody!.categoryBitMask = BitmaskCollision
            node.physicsBody!.physicsShape = SCNPhysicsShape(node: node, options: [SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConcavePolyhedron])
            
            // Get grass area to play the right sound steps
            if geometry.firstMaterial!.name == "grass-area" {
                if grassArea != nil {
                    geometry.firstMaterial = grassArea
                } else {
                    grassArea = geometry.firstMaterial
                }
            }
            
            // Get the water area
            if geometry.firstMaterial!.name == "water" {
                waterArea = geometry.firstMaterial
            }
            
            // Temporary workaround because concave shape created from geometry instead of node fails
            let childNode = SCNNode()
            node.addChildNode(childNode)
            childNode.hidden = true
            childNode.geometry = node.geometry
            node.geometry = nil
            node.hidden = false
            
            if node.name == "water" {
                node.physicsBody!.categoryBitMask = BitmaskWater
            }
        }
        
        for childNode in node.childNodes {
            if childNode.hidden == false {
                setupCollisionNode(childNode)
            }
        }
    }
    
    // MARK: Collecting Items
    
    private func removeNode(node: SCNNode, soundToPlay sound: SCNAudioSource) {
        if let parentNode = node.parentNode {
            let soundEmitter = SCNNode()
            soundEmitter.position = node.position
            parentNode.addChildNode(soundEmitter)
            
            soundEmitter.runAction(SCNAction.sequence([
                SCNAction.playAudioSource(sound, waitForCompletion: true),
                SCNAction.removeFromParentNode()]))
            
            node.removeFromParentNode()
        }
    }
    
    func collectPearl(pearlNode: SCNNode) {
        if pearlNode.parentNode != nil {
            removeNode(pearlNode, soundToPlay:self.collectPearlSound)
            model.applyCollectedPearlsUpdate()
        }
    }
    
    private var collectFlowerParticleSystem: SCNParticleSystem!
    
    private func initializeCollectFlowerParticleSystem() {
        collectFlowerParticleSystem = SCNParticleSystem(named: "collect.scnp", inDirectory: nil)
        collectFlowerParticleSystem.loops = false
    }
    
    private func emitFlowerParticles(flowerNode : SCNNode) {
        var particleSystemPosition = flowerNode.worldTransform
        particleSystemPosition.m42 += 0.1
        scene.addParticleSystem(collectFlowerParticleSystem, withTransform: particleSystemPosition)
    }
    
    func collectFlower(flowerNode: SCNNode) {
        if flowerNode.parentNode != nil {
            emitFlowerParticles(flowerNode)
            removeNode(flowerNode, soundToPlay:collectFlowerSound)
            model.applyCollectedFlowersUpdate()
           
        }
    }
    
    // MARK: Congratulating the Player
    
    private var confettiParticleSystem: SCNParticleSystem!
    
    private func initializeConfettiParticleSystem() {
        confettiParticleSystem = SCNParticleSystem(named: "confetti.scnp", inDirectory: nil)
    }
    
    private func addConfettis() {
        let particleSystemPosition = SCNMatrix4MakeTranslation(0.0, 8.0, 0.0)
        scene.addParticleSystem(confettiParticleSystem, withTransform: particleSystemPosition)
    }
    
    private func stopTheMusic() {
        scene.rootNode.removeAllAudioPlayers()
    }
    
    private func playCongratSound() {
        scene.rootNode.addAudioPlayer(SCNAudioPlayer(source: victoryMusic))
    }
    
    private func showEndAnimation() {
        addConfettis()
        stopTheMusic()
        playCongratSound()
        cameraManipulator.animateTheCameraForever()
    }
}

extension Game {
    
    private func resetFoxCharacterStates() {
        foxCharacter.replacementPosition = nil
        foxCharacter.maxPenetrationDistance = 0
    }
    
    private func groundTypeFromMaterial(material: SCNMaterial) -> GroundType {
        if material == grassArea {
            return .Grass
        }
        if material == waterArea {
            return .Water
        }
        else {
            return .Rock
        }
    }
    
    private func resetFlamesTransform() {
        // Flames are static physics bodies, but they are moved by an action - So we need to tell the physics engine that the transforms did change.
        for flame in flames {
            flame.physicsBody!.resetTransform()
        }
    }
    
    private func distanceToClosestEnemyOnGame() -> Float {
        var distanceToClosestEnemy = Float.infinity
        let characterPosition = float3(foxCharacter.node.position)
        for enemy in enemies {
            //distance to enemy
            let enemyTransform = float4x4(enemy.worldTransform)
            let enemyPosition = float3(enemyTransform[3].x, enemyTransform[3].y, enemyTransform[3].z)
            let distance = simd.distance(characterPosition, enemyPosition)
            distanceToClosestEnemy = min(distanceToClosestEnemy, distance)
        }
        
        return distanceToClosestEnemy
    }
    
    private func adjustSoundsVolumesBasedOnDistance(distanceToClosestEnemy: Float) {
        // Adjust sounds volumes based on distance with the enemy.
        if !model.isWin() {
            if let mixer = flameThrowerSound!.audioNode as? AVAudioMixerNode {
                mixer.volume = 0.3 * max(0, min(1, 1 - ((distanceToClosestEnemy - 1.2) / 1.6)))
            }
        }
    }
    
    func walkFoxCharacterIntoGround(time: NSTimeInterval) -> SCNNode? {
        let direction = characterDirection(model.controllerDirection())
        let groundNode = foxCharacter.walkInDirection(direction, time: time, scene: scene, groundTypeFromMaterial:groundTypeFromMaterial)
        return groundNode
    }
    
    func adjustTheVolumeOfTheEnemyBasedOnTheDistanceToTheCharacter() {
        let distanceToClosestEnemy = distanceToClosestEnemyOnGame()
        adjustSoundsVolumesBasedOnDistance(distanceToClosestEnemy)
    }
}

extension Game {

    func updateGameAtTime(time: NSTimeInterval) {
        resetFoxCharacterStates()
        resetFlamesTransform()
        adjustTheVolumeOfTheEnemyBasedOnTheDistanceToTheCharacter()
        
        if let groundNode = walkFoxCharacterIntoGround(time) {
            updateCameraWithCurrentGround(groundNode)
        }     
    }
}

extension Game {
    func didSimulatePhysicsOfGameAtTime(time: NSTimeInterval) {
        // If we hit a wall, position needs to be adjusted
        if let position = foxCharacter.replacementPosition {
            foxCharacter.node.position = position
        }
    }
}

extension Game : GameModelDelegate {
    func didApplyGameModelUpdate(gameModel: GameModel) {
        if model.isWin() {
            showEndAnimation()
        }
    }
}