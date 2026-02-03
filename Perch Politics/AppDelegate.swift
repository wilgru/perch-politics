//
//  AppDelegate.swift
//  Perch Politics
//
//  Created by Matusalem Marques on 2017/02/17.
//

import Cocoa
import CoreGraphics
import SpriteKit
import GameplayKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let flockContext = FlockContext()
    
    var birdInstances: [Bird] = []
    var otherTimers: [Timer] = []
    
    @IBOutlet var menu : NSMenu!
    
    @IBOutlet var skinMenu : NSMenu! {
        didSet {
            for item in skinMenu.items {
                item.state = .off
            }
        }
    }
    
    @IBOutlet var barSkinMenu : NSMenu! {
        didSet {
            for item in barSkinMenu.items {
                item.state = .off
            }
        }
    }
    
    @IBOutlet var dockMenu : NSMenu!
    
    @IBOutlet var dockSkinMenu : NSMenu! {
        didSet {
            for item in dockSkinMenu.items {
                item.state = .off
            }
        }
    }
    
    @IBAction func setSkin(_ sender: NSMenuItem) {
        // Skin selection disabled: using hardcoded per-bird skins
        return
    }
    
    @objc func updateStateMachineLegacy(_ timer: Timer) {
        guard let machine = timer.userInfo as? GKStateMachine else { return }
        machine.update(deltaTime: timer.timeInterval)
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        return dockMenu
    }
    
    func createStateMachine(birdIdentity: BirdIdentity, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow) -> GKStateMachine {
        let birdStates = [
            BirdIsStopped(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            BirdIsLicking(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            BirdIsScratching(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            BirdIsYawning(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            BirdIsSleeping(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            BirdIsAwake(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            BirdIsMoving(birdIdentity: birdIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        ]
        let stateMachine = GKStateMachine(states: birdStates)
        stateMachine.enter(BirdIsAwake.self)

        return stateMachine
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let flockStateMachine = GKStateMachine(states: [FlockState(flockContext: flockContext)])
        flockStateMachine.enter(FlockState.self)
        
        let flockTimer = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true) { timer in
            flockStateMachine.update(deltaTime: timer.timeInterval)
        }
        RunLoop.current.add(flockTimer, forMode: .common)
        otherTimers.append(flockTimer)
        
        let rect = NSRect(x: 0, y: 0, width: 64, height: 64)
        for birdIdentity in BirdIdentity.allCases {
            let scene = SKScene(size: rect.size)
            scene.backgroundColor = NSColor.clear
            
            let sprite = SKSpriteNode(texture: SKTextureAtlas(named: birdIdentity.atlasName).textureNamed("awake"))
            sprite.anchorPoint = NSPoint.zero
            
            scene.addChild(sprite)

            let spriteView = SKView()
            spriteView.allowsTransparency = true
            spriteView.presentScene(scene)
            spriteView.menu = menu

            let window = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
            window.backgroundColor = NSColor.clear
            window.hasShadow = false  // Shadow is not updated when sprite changes
            window.isMovableByWindowBackground = true
            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow))) // Over all windows and menu bar, but under the screen saver
            window.ignoresMouseEvents = false
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
            window.contentView = spriteView
            window.center()

            let windowController = NSWindowController(window: window)
            windowController.showWindow(self)
            
            let birdStateMachine = createStateMachine(birdIdentity: birdIdentity, sprite: sprite, textures: SKTextureAtlas(named: birdIdentity.atlasName), window: window)
            
            let birdTimer = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true) { timer in
                birdStateMachine.update(deltaTime: timer.timeInterval)
            }
            RunLoop.current.add(birdTimer, forMode: .common)
            
            // create class instance
            let birdInstance = Bird(birdIdentity: birdIdentity, stateMachine: birdStateMachine, timer: birdTimer)
            birdInstances.append(birdInstance)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        for birdInstance in birdInstances {
            birdInstance.timer.invalidate()
        }
        
        for otherTimer in otherTimers {
            otherTimer.invalidate()
        }
    }
}
