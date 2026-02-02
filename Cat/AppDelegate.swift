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
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        return dockMenu
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
        
//        // Create multiple cat sprites
//        catSprites = []
//        catDestinationOffsets = []
//        for (index, config) in catConfigs.enumerated() {
//            let atlasName = config.atlasName
//            let sprite = SKSpriteNode(texture: SKTextureAtlas(named: atlasName).textureNamed("awake"))
//            sprite.anchorPoint = NSPoint.zero
//            
//            // Stagger initial positions so cats don't overlap (e.g., horizontal offset)
//            sprite.position = CGPoint(x: CGFloat(index) * (sprite.size.width + catSpacing), y: 0)
//            catSprites.append(sprite)
//            
//            // Per-cat destination offset so they aim at different x positions near the perch
//            let offsetX = CGFloat(index) * (sprite.size.width + catSpacing)
//            catDestinationOffsets.append(NSPoint(x: offsetX, y: 0))
//        }
        
        // Iterate over each cat sprite and create windows, statemachine and timer
//        windows = []
//        stateMachines = []
//        timers = []
//        for (index, config) in catConfigs.enumerated() {
//            // Create a new scene and single sprite for this window
//            let scene = SKScene(size: rect.size)
//            scene.backgroundColor = NSColor.clear
//            
//            let atlasName = config.atlasName
//            let sprite = SKSpriteNode(texture: SKTextureAtlas(named: atlasName).textureNamed("awake"))
//            sprite.anchorPoint = NSPoint.zero
//            
//            scene.addChild(sprite)
//            
//            // Replace the stored sprite with this instance bound to this window
//            catSprites[index] = sprite
//
//            let spriteView = SKView()
//            spriteView.allowsTransparency = true
//            spriteView.presentScene(scene)
//            spriteView.menu = menu
//
//            let window = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
//            window.backgroundColor = NSColor.white // TODO: change back to .clear
//            window.hasShadow = false  // Shadow is not updated when sprite changes
//            window.isMovableByWindowBackground = true
//            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow))) // Over all windows and menu bar, but under the screen saver
//            window.ignoresMouseEvents = false
//            window.collectionBehavior = [.canJoinAllSpaces, .stationary]
//            window.contentView = spriteView
//            window.center()
//
//            let windowController = NSWindowController(window: window)
//            windowController.showWindow(self)
//
//            windows.append(window)
//
//            let machine = createStateMachine(sprite: sprite, textures: SKTextureAtlas(named: atlasName))
//            stateMachines.append(machine)
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        for catInstance in catInstances {
            catInstance.timer.invalidate()
        }
        
        for otherTimer in otherTimers {
            otherTimer.invalidate()
        }
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
    
//    struct playfield: CatPlayfield {
//        let window: NSWindow
//        let offset: NSPoint
//        
//        var destination: NSPoint {
//            let perchPosition = window.topOfActiveWindowOrDockOrBottom
//            let base = NSPoint(x: perchPosition.leftX - 32, y: perchPosition.topY)
//            
//            return NSPoint(x: base.x + offset.x, y: base.y + offset.y)
//        }
//    }
    
    @objc func updateStateMachineLegacy(_ timer: Timer) {
        guard let machine = timer.userInfo as? GKStateMachine else { return }
        machine.update(deltaTime: timer.timeInterval)
    }
}

//extension SKView {
//    open override func rightMouseDown(with event: NSEvent) {
//        super.rightMouseDown(with: event)
//    }
//}
//
//extension AppDelegate : CatPlayfield {
//    var catPosition : NSPoint {
//        get { return windows.first?.frame.origin ?? .zero }
//        set { windows.first?.setFrameOrigin(newValue) }
//    }
//    
//    var destination : NSPoint {
//        return destinationForCat(at: 0)
//    }
//    
//    var catCanMove : Bool {
//        if let win = windows.first {
//            return !win.frame.contains(NSEvent.mouseLocation)
//        }
//        return true
//    }
//}

