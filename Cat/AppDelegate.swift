//
//  AppDelegate.swift
//  Cat
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
    
    let initialPosition = NSPoint(x: 0, y: 0)
    let catSpacing: CGFloat = 10
    
    var catInstances: [CatInstance] = []
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
        // Skin selection disabled: using hardcoded per-cat skins
        return
    }
    
    @objc func updateStateMachineLegacy(_ timer: Timer) {
        guard let machine = timer.userInfo as? GKStateMachine else { return }
        machine.update(deltaTime: timer.timeInterval)
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        return dockMenu
    }
    
    func createStateMachine(catIdentity: Cat, sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow) -> GKStateMachine {
        let catStates = [
            CatIsStopped(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            CatIsLicking(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            CatIsScratching(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            CatIsYawning(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            CatIsSleeping(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            CatIsAwake(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext),
            CatIsMoving(catIdentity: catIdentity, sprite: sprite, textures: textures, window: window, flockContext: flockContext)
        ]
        let stateMachine = GKStateMachine(states: catStates)
        stateMachine.enter(CatIsAwake.self)

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
        for cat in Cat.allCases {
            let scene = SKScene(size: rect.size)
            scene.backgroundColor = NSColor.clear
            
            let sprite = SKSpriteNode(texture: SKTextureAtlas(named: cat.atlasName).textureNamed("awake"))
            sprite.anchorPoint = NSPoint.zero
            
            scene.addChild(sprite)

            let spriteView = SKView()
            spriteView.allowsTransparency = true
            spriteView.presentScene(scene)
            spriteView.menu = menu

            let window = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
            window.backgroundColor = NSColor.white // TODO: change back to .clear
            window.hasShadow = false  // Shadow is not updated when sprite changes
            window.isMovableByWindowBackground = true
            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow))) // Over all windows and menu bar, but under the screen saver
            window.ignoresMouseEvents = false
            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
            window.contentView = spriteView
            window.center()

            let windowController = NSWindowController(window: window)
            windowController.showWindow(self)
            
            let catStateMachine = createStateMachine(catIdentity: cat, sprite: sprite, textures: SKTextureAtlas(named: cat.atlasName), window: window)
            
            let catTimer = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true) { timer in
                catStateMachine.update(deltaTime: timer.timeInterval)
            }
            RunLoop.current.add(catTimer, forMode: .common)
            
            // create class instance
            let catInstance = CatInstance(cat: cat, stateMachine: catStateMachine, timer: catTimer)
            catInstances.append(catInstance)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        for catInstance in catInstances {
            catInstance.timer.invalidate()
        }
        
        for otherTimer in otherTimers {
            otherTimer.invalidate()
        }
    }
}
