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
    var catInstances: [CatInstance] = []
    let catSpacing: CGFloat = 10 // TODO: make constant?
    
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
        let rect = NSRect(x: 0, y: 0, width: 64, height: 64)
        
        for (index, cat) in Cat.allCases.enumerated() {
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

            // Per-cat destination offset so they aim at different x positions near the perch
            let offsetX = CGFloat(index) * (sprite.size.width + catSpacing)
            let offset: NSPoint = NSPoint(x: offsetX, y: 0)
            
            let stateMachine = createStateMachine(sprite: sprite, textures: SKTextureAtlas(named: cat.atlasName), window: window, offset: offset)
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true) { timer in
                stateMachine.update(deltaTime: timer.timeInterval)
            }
            RunLoop.current.add(timer, forMode: .common)
            
            // create class instance
            let catInstance = CatInstance(cat: cat, stateMachine: stateMachine, timer: timer)
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
    }
    
    func createStateMachine(sprite: SKSpriteNode, textures: SKTextureAtlas, window: NSWindow, offset: NSPoint) -> GKStateMachine {
        let catStates = [
            CatIsStopped(sprite: sprite, playfield: playfield(window: window, offset: offset), textures: textures),
            CatIsLicking(sprite: sprite, playfield: playfield(window: window, offset: offset), textures: textures),
            CatIsScratching(sprite: sprite, playfield: playfield(window: window, offset: offset), textures: textures),
            CatIsYawning(sprite: sprite, playfield: playfield(window: window, offset: offset), textures: textures),
            CatIsSleeping(sprite: sprite, playfield: playfield(window: window, offset: offset), textures: textures),
            CatIsAwake(sprite: sprite, playfield: playfield(window: window, offset: offset), textures: textures),
            CatIsMoving(sprite: sprite, playfield: playfield(window: window, offset: offset), textures: textures)
        ]
        let stateMachine = GKStateMachine(states: catStates)
        stateMachine.enter(CatIsAwake.self)
        
        return stateMachine
    }
    
    struct playfield: CatPlayfield {
        let window: NSWindow
        let offset: NSPoint
        
        var catPosition: NSPoint {
            get {
                return window.frame.origin
            }
            set {
                window.setFrameOrigin(newValue)
            }
        }
        var destination: NSPoint {
            let perchPosition = window.topOfActiveWindowOrDockOrBottom
            let base = NSPoint(x: perchPosition.leftX - 32, y: perchPosition.topY)
            
            return NSPoint(x: base.x + offset.x, y: base.y + offset.y)
        }
    }
    
    @objc func updateStateMachineLegacy(_ timer: Timer) {
        guard let machine = timer.userInfo as? GKStateMachine else { return }
        machine.update(deltaTime: timer.timeInterval)
    }
}

extension NSWindow {
    var topOfActiveWindowOrDockOrBottom: (
        leftX: Double,
        rightX: Double,
        topY: Double
    ) {
        return self.activeWindowGeometry ?? self.dockGeometry ?? (32, 0, 0)
    }
    
    var activeWindowGeometry: (
        leftX: Double,
        rightX: Double,
        topY: Double
    )? {
        let options = CGWindowListOption.optionOnScreenOnly
        guard let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: AnyObject]] else {
            print("Could not get window list")
            return nil
        }
        
        guard let screenHeight = NSScreen.main?.frame.height else {
            print("Could not find main screen")
            return nil
        }

        guard let frontAppPID = NSWorkspace.shared.frontmostApplication?.processIdentifier else {
            print("Could not find front app PID")
            return nil
        }
        
        for window in windowList {
            if let windowPID = window[kCGWindowOwnerPID as String] as? Int,
               let boundsAny = window[kCGWindowBounds as String],
               let layer = window[kCGWindowLayer as String] as? Int,
                   windowPID == frontAppPID,
                   layer == 0 // layer 0 for normal windows
                {
                if CFGetTypeID(boundsAny as CFTypeRef) == CFDictionaryGetTypeID() {
                    guard let bounds = CGRect(dictionaryRepresentation: boundsAny as! CFDictionary) else {
                        print("Could not convert type of bounds to CFDictionary")
                        return nil
                    }
                    
                    return (
                        leftX: Double(bounds.origin.x + 32 + 30), //30 for corner radius
                        rightX:  Double(bounds.origin.x + bounds.size.width - 32),
                        topY:  Double(screenHeight - bounds.origin.y)
                    )
                }
            }
        }
        print("Could not find a window to get geometry for")
        return nil
    }
    
    var dockGeometry: (
        leftX: Double,
        rightX: Double,
        topY: Double
    )? {
        guard let screen = NSScreen.main else {
            print("Could not get main screen")
            return nil
        }

        let frame = screen.frame
        let visible = screen.visibleFrame

        // Dock must be at the bottom
        guard visible.minY > frame.minY else {
            // Dock is on the side, autohidden, or not present
            return nil
        }

        let centerX = frame.midX
        let topY = visible.minY

        return (
            leftX: Double(centerX),
            rightX: Double(centerX),
            topY: Double(topY)
        )
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

