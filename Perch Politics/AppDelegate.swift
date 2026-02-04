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
    var otherTimers: [Timer] = []
    
    let initialBirdNames = UserDefaults.standard.stringArray(forKey: "initialBirdNames") ?? {
        let fallback = [BirdIdentity.kyra.name]
        UserDefaults.standard.set(fallback, forKey: "initialBirdNames")
        return fallback
    }()
    
    var birdInstances: [Bird] = [] {
        didSet {
            let birdNames = birdInstances.map { $0.birdIdentity.name }
            
            for menu in [skinMenu, barSkinMenu, dockSkinMenu] {
                for item in menu!.items {
                    item.state = birdNames.contains { birdName in
                        item.title == birdName
                    } ? .on : .off
                }
            }
            
            UserDefaults.standard.set(birdNames, forKey: "initialBirdNames") // TODO: move this to the create and destroy methods? so that we can call removeAll on this array at termination without it affecting the UserDefaults
        }
    }
    
    let rect = NSRect(x: 0, y: 0, width: 64, height: 64) // TODO: make const
    
    @IBOutlet var menu : NSMenu!
    
    @IBOutlet var skinMenu : NSMenu! { // toggled bird menu
        didSet {
//            for item in skinMenu.items {
//                let birdIsToggled = initialBirdNames.contains { birdName in
//                    birdName == item.title
//                }
//                
//                item.state = birdIsToggled ? .on : .off
//            }
        }
    }
    
    @IBOutlet var barSkinMenu : NSMenu! { // bar toggled bird menu
        didSet {
//            for item in barSkinMenu.items {
//                let birdIsToggled = initialBirdNames.contains { birdName in
//                    birdName == item.title
//                }
//                
//                item.state = birdIsToggled ? .on : .off
//            }
        }
    }
    
    @IBOutlet var dockMenu : NSMenu!
    
    @IBOutlet var dockSkinMenu : NSMenu! { // dock toggled bird menu
        didSet {
//            for item in dockSkinMenu.items {
//                let birdIsToggled = initialBirdNames.contains { birdName in
//                    birdName == item.title
//                }
//                
//                item.state = birdIsToggled ? .on : .off
//            }
        }
    }
    
    @IBAction func toggleBird(_ sender: NSMenuItem) {
        // TODO: find bird in birdInstances and create or destroy - didSet on that array will update menus and userdefaults to add/remove bird name
        let birdToToggleName = sender.title
        guard let birdToToggleIdentity = BirdIdentity.from(name: birdToToggleName) else { return }
        
        let existingBirdInstance = birdInstances.first { birdInstace in
            birdInstace.birdIdentity == birdToToggleIdentity
        }
        
        if (existingBirdInstance == nil) {
            createBird(birdIdentity: birdToToggleIdentity)
        } else {
            destroyBird(birdToRemoveByIdentity: birdToToggleIdentity)
        }
        
        return
    }
    
    // TODO: still needed?
    @objc func updateStateMachineLegacy(_ timer: Timer) {
        guard let machine = timer.userInfo as? GKStateMachine else { return }
        machine.update(deltaTime: timer.timeInterval)
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
        
        let initialBirdIdentities = BirdIdentity.allCases.filter { birdIdentity in
            initialBirdNames.contains(birdIdentity.name)
        }
        for birdIdentity in initialBirdIdentities {
            createBird(birdIdentity: birdIdentity)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        for birdInstance in birdInstances {
            birdInstance.timer.invalidate()
        }
//        birdInstances.removeAll() // this will trigger the didSet on the array, so you might loose the UserDefaults then
        
        for otherTimer in otherTimers {
            otherTimer.invalidate()
        }
    }
    
    // TODO: start to move all this to the bird class and init there - make the bird own its states and whatnot closer
    func createBird(birdIdentity: BirdIdentity) {
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
        window.center() // TODO: make the window start somehwere else

        let windowController = NSWindowController(window: window)
        windowController.showWindow(self)
        
        let birdStateMachine = createStateMachine(birdIdentity: birdIdentity, sprite: sprite, textures: SKTextureAtlas(named: birdIdentity.atlasName), window: window)
        
        let birdTimer = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true) { timer in
            birdStateMachine.update(deltaTime: timer.timeInterval)
        }
        RunLoop.current.add(birdTimer, forMode: .common)
        
        // create class instance
        let birdInstance = Bird(windowController: windowController, birdIdentity: birdIdentity, stateMachine: birdStateMachine, timer: birdTimer)
        birdInstances.append(birdInstance)
    }
    
    func destroyBird(birdToRemoveByIdentity: BirdIdentity) {
        birdInstances.removeAll { birdInstance in
            birdInstance.birdIdentity == birdToRemoveByIdentity
        }
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
}
