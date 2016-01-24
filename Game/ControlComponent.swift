//
//  ControlComponent.swift
//  Game
//
//  Created by Julio César Guzman on 1/20/16.
//  Copyright © 2016 Julio. All rights reserved.
//

import Foundation
import GameplayKit
import SceneKit

class ControlComponent: GKComponent {
    
    private let speed = Float(0.000001)
    private var controllerDirection = { () in return float2() }
    private weak var node : SCNNode!
    
    init(controllerDirection: ()->float2, node : SCNNode) {
        super.init()
        self.node = node
        self.controllerDirection = controllerDirection
    }
    
    override func updateWithDeltaTime(seconds: NSTimeInterval) {
        changePositionWithDeltaTime(seconds)
    }
    
    private func changePositionWithDeltaTime(seconds: NSTimeInterval) {
        let direction = float3(controllerDirection().x,0.0,controllerDirection().y)
        let deltaTime = Float(seconds)
        let deltaX = deltaTime * speed
        let position = float3(node.position)
        node.position = SCNVector3(position + direction * deltaX)
    }

}