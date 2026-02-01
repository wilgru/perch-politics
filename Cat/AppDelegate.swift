//
//  AppDelegate.swift
//  Cat
//
//  Created by Matusalem Marques on 2017/02/17.
//

import Cocoa
import CoreGraphics
import ApplicationServices
import SpriteKit
import GameplayKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window : NSWindow!
    var timer : Timer!
    var stateMachine : GKStateMachine!
    var catSprite : SKSpriteNode!
    
    var skinName : String = UserDefaults.standard.string(forKey: "skinName") ?? "White Cat" {
        didSet {
            for menu in [skinMenu, barSkinMenu, dockSkinMenu] {
                for item in menu!.items {
                    item.state = (item.representedObject as? String) == skinName ? .on : .off
                }
            }
        }
    }
    
    @IBOutlet var menu : NSMenu!
    
    @IBOutlet var skinMenu : NSMenu! {
        didSet {
            for item in skinMenu.items {
                item.state = (item.representedObject as? String) == skinName ? .on : .off
            }
        }
    }
    
    @IBOutlet var barSkinMenu : NSMenu! {
        didSet {
            for item in barSkinMenu.items {
                item.state = (item.representedObject as? String) == skinName ? .on : .off
            }
        }
    }
    
    @IBOutlet var dockMenu : NSMenu!
    
    @IBOutlet var dockSkinMenu : NSMenu! {
        didSet {
            for item in dockSkinMenu.items {
                item.state = (item.representedObject as? String) == skinName ? .on : .off
            }
        }
    }
    
    @IBAction func setSkin(_ sender: NSMenuItem) {
        guard let skinName = sender.representedObject as? String else { return }
        self.skinName = skinName
        UserDefaults.standard.set(skinName, forKey: "skinName")
        
        let catTextures = SKTextureAtlas(named: skinName)
        stateMachine = createStateMachine(sprite: catSprite, textures: catTextures)
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        return dockMenu
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let options = [
            kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true
        ] as CFDictionary

        let trusted = AXIsProcessTrustedWithOptions(options)

        if !trusted {
            print("Accessibility permission not yet granted.")
        }
        
        let rect = NSRect(x: 0, y: 0, width: 64, height: 64)
        
        let catTextures = SKTextureAtlas(named: skinName)
        
        catSprite = SKSpriteNode(texture: catTextures.textureNamed("awake"))
        
        catSprite.anchorPoint = NSPoint.zero

        let scene = SKScene(size: rect.size)
        scene.backgroundColor = NSColor.clear
        scene.addChild(catSprite)
        
        let spriteView = SKView()
        spriteView.allowsTransparency = true
        spriteView.presentScene(scene)
        
        spriteView.menu = menu
        
        window = NSWindow(contentRect: rect, styleMask: .borderless, backing: .buffered, defer: false)
        window.backgroundColor = NSColor.white // TODO: change back to .clear
        window.hasShadow = false  // Shadow is not updated when sprite changes
        window.isMovableByWindowBackground = true
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow))) // Over all windows and menu bar, but under the screen saver
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces,.stationary]
        window.contentView = spriteView
        window.center()
    
        let windowController = NSWindowController(window: window)
        windowController.showWindow(self)

        stateMachine = createStateMachine(sprite: catSprite, textures: catTextures)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        timer.invalidate()
    }
    
    func createStateMachine(sprite: SKSpriteNode, textures: SKTextureAtlas) -> GKStateMachine {
        if timer != nil {
            timer.invalidate()
        }
        
        let catStates = [
            CatIsStopped(sprite: sprite, playfield: self, textures: textures),
            CatIsLicking(sprite: sprite, playfield: self, textures: textures),
            CatIsScratching(sprite: sprite, playfield: self, textures: textures),
            CatIsYawning(sprite: sprite, playfield: self, textures: textures),
            CatIsSleeping(sprite: sprite, playfield: self, textures: textures),
            CatIsAwake(sprite: sprite, playfield: self, textures: textures),
            CatIsMoving(sprite: sprite, playfield: self, textures: textures)
        ]
        let stateMachine = GKStateMachine(states: catStates)
        stateMachine.enter(CatIsAwake.self)
        
        if #available(OSX 10.12, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true) { timer in
                self.stateMachine.update(deltaTime: timer.timeInterval)
            }
        } else {
            timer = Timer.scheduledTimer(timeInterval: 0.125, target: self, selector: #selector(updateStateMachine), userInfo: nil, repeats: true)
        }
        RunLoop.current.add(timer, forMode: .common)
        
        return stateMachine
    }
    
    @objc func updateStateMachine() {
        self.stateMachine.update(deltaTime: timer.timeInterval)
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

extension SKView {
    open override func rightMouseDown(with event: NSEvent) {
        super.rightMouseDown(with: event)
    }
}

extension AppDelegate : CatPlayfield {
    var catPosition : NSPoint {
        get { return window.frame.origin }
        set { window.setFrameOrigin(newValue) }
    }
    
    var destination : NSPoint {
        let perchPosition = window.topOfActiveWindowOrDockOrBottom // Touch to ensure computed and available if needed later
        return NSPoint(x: perchPosition.leftX - 32, y: perchPosition.topY)
    }
    
    var catCanMove : Bool {
        return !window.frame.contains(NSEvent.mouseLocation)
    }
}

