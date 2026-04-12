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
    // TODO: make consts
    private enum SpawnEdge: CaseIterable {
        case left
        case right
        case top
    }
    private let birdSize = NSSize(width: 64, height: 64)
    private let activeWindowLevel = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow)))
    private let settledWindowLevel = NSWindow.Level(rawValue: NSWindow.Level.normal.rawValue - 1)

    weak let flock: Flock?
    let birdIdentity: BirdIdentity
    
    var spawned = false
    var sprite: SKSpriteNode
    var textures: SKTextureAtlas
    var windowController: NSWindowController?
    var stateMachine: GKStateMachine?
    var direction: BirdDirection = .left
    var velocity: NSPoint = NSPoint(x: 1, y: 1)
    
    var position: NSPoint {
        didSet {
            self.windowController?.window?.setFrameOrigin(position)
        }
    }
    
    var distance: CGFloat {
        get {
            return hypot(actualDesitnation.x - self.position.x, actualDesitnation.y - self.position.y)
        }
    }
    
    var actualDesitnation: NSPoint {
        get {
            guard let flock = flock else { return .zero }
            
            let order = settledOrder ?? flock.settledBirdsCount
            return NSPoint(x: flock.destination.x + CGFloat(order * 64), y: flock.destination.y) // TODO: use const for 64?
        }
    }
    
    var settledOrder: Int? {
        didSet {
            guard settledOrder != nil else { return }
            moveWindowToBack()
        }
    }

    private func randomSpawnPosition() -> NSPoint {
        guard let screenFrame = NSScreen.main?.frame else {
            return NSPoint(x: actualDesitnation.x - birdSize.width, y: actualDesitnation.y + birdSize.height)
        }

        let maxSpawnX = max(screenFrame.minX, screenFrame.maxX - birdSize.width)
        let maxSpawnY = max(screenFrame.minY, screenFrame.maxY - birdSize.height)

        switch SpawnEdge.allCases.randomElement()! {
        case .left:
            return NSPoint(
                x: screenFrame.minX - birdSize.width,
                y: CGFloat.random(in: screenFrame.minY...maxSpawnY)
            )
        case .right:
            return NSPoint(
                x: screenFrame.maxX,
                y: CGFloat.random(in: screenFrame.minY...maxSpawnY)
            )
        case .top:
            return NSPoint(
                x: CGFloat.random(in: screenFrame.minX...maxSpawnX),
                y: screenFrame.maxY
            )
        }
    }

    func moveWindowToFront() {
        guard let window = windowController?.window else { return }

        window.level = activeWindowLevel
        window.orderFrontRegardless()
    }

    func moveWindowToBack() {
        guard let window = windowController?.window else { return }

        window.level = settledWindowLevel
        window.orderBack(nil)
    }
    
    func spawn() {
        guard let flock = flock else { return }
        guard !spawned else { return }
        
        position = randomSpawnPosition()

        let rect = NSRect(origin: .zero, size: birdSize)
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
        window.level = activeWindowLevel // Over all windows and menu bar, but under the screen saver
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.contentView = spriteView
        window.setFrameOrigin(position)
        
        let windowController = NSWindowController(window: window)
        windowController.showWindow(self)
        
        let stateMachine = GKStateMachine(states: [
            BirdIsIdle(flock: flock, bird: self),
            BirdIsBlinking(flock: flock, bird: self),
            BirdIsStretching(flock: flock, bird: self),
            BirdIsFlying(flock: flock, bird: self),
        ])
        stateMachine.enter(BirdIsIdle.self)
        
        self.windowController = windowController
        self.stateMachine = stateMachine
        self.spawned = true
        
        moveWindowToFront()
    }
    
    func despawn() {
        guard spawned else { return }
        
        windowController?.close()
        
        self.spawned = false
        self.stateMachine = nil
        self.windowController = nil
    }
    
    func toggleSpawn() {
        spawned ? despawn() : spawn()
    }
    
    func update(deltaTime: TimeInterval) {
        guard spawned else { return }
        stateMachine?.update(deltaTime: deltaTime)
    }
    
    init(
        flock: Flock,
        birdIdentity: BirdIdentity
    ) {
        self.flock = flock
        self.birdIdentity = birdIdentity
        
        let sprite = SKSpriteNode(texture: SKTextureAtlas(named: birdIdentity.atlasName).textureNamed("idle_left"))
        sprite.anchorPoint = NSPoint.zero
        self.sprite = sprite
        self.textures = SKTextureAtlas(named: birdIdentity.atlasName)
        self.position = .zero
    }
    
    deinit {
        despawn()
    }
}
