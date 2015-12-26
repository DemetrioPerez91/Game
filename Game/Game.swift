//
//  Game.swift
//  Game
//
//  Created by Julio César Guzman on 12/26/15.
//  Copyright © 2015 Julio. All rights reserved.
//

import Foundation
import SceneKit

class Game: NSObject {
    var isComplete = false
    var grassArea: SCNMaterial!
    var waterArea: SCNMaterial!
    var flames = [SCNNode]()
    var enemies = [SCNNode]()
    var collectPearlSound: SCNAudioSource!
    var collectFlowerSound: SCNAudioSource!
    var flameThrowerSound: SCNAudioPlayer!
    var victoryMusic: SCNAudioSource!
}