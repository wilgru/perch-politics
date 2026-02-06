//
//  Bird.swift
//  Perch Politics
//
//  Created by William Gruszka on 1/2/2026.
//  Copyright © 2026 Matusalem Marques. All rights reserved.
//

import AppKit
import SpriteKit
import GameplayKit

final class Bird {
    weak let flock: Flock?
    
    var sprite: SKSpriteNode
    var textures: SKTextureAtlas
    var windowController: NSWindowController
    var stateMachine: GKStateMachine?
    var timer: Timer?
    
    let birdIdentity: BirdIdentity
    var spawned = false
    var settledOrder: Int?
    var velocity: NSPoint = NSPoint(x: 1, y: 1)
    var position: NSPoint {
        didSet {
            self.windowController.window?.setFrameOrigin(position)
        }
    }
    var actualDesitnation: NSPoint {
        get {
            guard let flock = flock else { return .zero }
            
            let order = settledOrder ?? flock.settledBirdsCount
            return NSPoint(x: flock.destination.x + CGFloat(order * 64), y: flock.destination.y) // TODO: use const for 64?
        }
    }
    var distance: CGFloat {
        get {
            return hypot(actualDesitnation.x - self.position.x, actualDesitnation.y - self.position.y)
        }
    }

    init(
        flock: Flock,
        birdIdentity: BirdIdentity
    ) {
        self.flock = flock
        self.birdIdentity = birdIdentity
        
        let sprite = SKSpriteNode(texture: SKTextureAtlas(named: birdIdentity.atlasName).textureNamed("awake"))
        sprite.anchorPoint = NSPoint.zero
        self.sprite = sprite
        self.textures = SKTextureAtlas(named: birdIdentity.atlasName)
        
        let rect = NSRect(x: 0, y: 0, width: 64, height: 64) // TODO: make const
        let scene = SKScene(size: rect.size)
        scene.backgroundColor = NSColor.clear
        scene.addChild(sprite)
        
        let spriteView = SKView()
        spriteView.allowsTransparency = true
        spriteView.presentScene(scene)
//        spriteView.menu = menu
        
        let window = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
        window.backgroundColor = NSColor.clear
        window.hasShadow = false  // Shadow is not updated when sprite changes
        window.isMovableByWindowBackground = true
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow))) // Over all windows and menu bar, but under the screen saver
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.contentView = spriteView
        window.center() // TODO: make the window start somehwere else
        
        let windowController = NSWindowController(window: window)
        
        self.windowController = windowController
        self.position = windowController.window?.frame.origin ?? .zero
    }
    
    func spawn() {
        guard let flock = flock else { return }
        guard !spawned else { return }
        
        let birdStates = [
            BirdIsStopped(flock: flock, bird: self),
            BirdIsLicking(flock: flock, bird: self),
            BirdIsScratching(flock: flock, bird: self),
            BirdIsYawning(flock: flock, bird: self),
            BirdIsSleeping(flock: flock, bird: self),
            BirdIsAwake(flock: flock, bird: self),
            BirdIsMoving(flock: flock, bird: self),
        ]
        let stateMachine = GKStateMachine(states: birdStates)
        stateMachine.enter(BirdIsAwake.self)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true) { timer in
            stateMachine.update(deltaTime: timer.timeInterval)
        }
        RunLoop.current.add(timer, forMode: .common)
        
        self.stateMachine = stateMachine
        self.timer = timer
        self.spawned = true
        
        self.windowController.showWindow(self)
    }
    
    func despawn() {
        guard spawned else { return }
        
        timer?.invalidate()
        windowController.close()
        spawned = false
        
        self.timer = nil
        self.stateMachine = nil
    }
    
    func toggleSpawn() {
        spawned ? despawn() : spawn()
    }

    deinit {
        despawn()
    }
}
