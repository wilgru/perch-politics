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
    let flock = Flock()
    var otherTimers: [Timer] = []
    
    let initialBirdNames = UserDefaults.standard.stringArray(forKey: "initialBirdNames") ?? {
        let fallback = [BirdIdentity.kyra.name]
        UserDefaults.standard.set(fallback, forKey: "initialBirdNames")
        return fallback
    }()
    
    @IBOutlet var barChickensMenu : NSMenu!
    @IBOutlet var dockMenu : NSMenu! // TODO: is this still needed?
    @IBOutlet var dockChickensMenu : NSMenu!
    
    @IBAction func toggleBird(_ sender: NSMenuItem) {
        let birdToToggleName = sender.title
        
        let bird = flock.birds.first { bird in
            bird.birdIdentity.name == birdToToggleName
        }
        bird?.toggleSpawn()
        
        updateMenus()
    }
    
    // TODO: still needed?
    @objc func updateStateMachineLegacy(_ timer: Timer) {
        guard let machine = timer.userInfo as? GKStateMachine else { return }
        machine.update(deltaTime: timer.timeInterval)
    }
    
    func updateMenus() {
        let spawnedBirdNames = flock.spawnedBirds.map { $0.birdIdentity.name }
        for menu in [barChickensMenu, dockChickensMenu] {
            for item in menu!.items {
                item.state = spawnedBirdNames.contains { birdName in
                    item.title == birdName
                } ? .on : .off
            }
        }
        
        UserDefaults.standard.set(spawnedBirdNames, forKey: "initialBirdNames")
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        return dockMenu
    } // TODO: is this still needed?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let flockTimer = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true) { timer in
            self.flock.updateDestination()
        }
        RunLoop.current.add(flockTimer, forMode: .common)
        otherTimers.append(flockTimer)
        
        let initialBirdIdentities = BirdIdentity.allCases.filter { birdIdentity in
            initialBirdNames.contains(birdIdentity.name)
        }
        
        for birdIdentity in BirdIdentity.allCases {
            let newBird = Bird(flock: flock, birdIdentity: birdIdentity)
            
            flock.birds.append(newBird)
        }
        
        for birdIdentity in initialBirdIdentities {
            flock.spawnBird(birdIdentity: birdIdentity)
        }
        
        updateMenus()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        for bird in flock.birds {
            bird.despawn()
        }
//        flockContext.birds.removeAll()
        
        for otherTimer in otherTimers {
            otherTimer.invalidate()
        }
    }
}
