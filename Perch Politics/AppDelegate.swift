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
    var updateTimer: Timer?
    
    let initialBirdNames = UserDefaults.standard.stringArray(forKey: "initialBirdNames") ?? {
        let fallback = [
            BirdIdentity.greenBub.name,
            BirdIdentity.fatFeet.name,
            BirdIdentity.peg.name,
            BirdIdentity.chico.name,
            BirdIdentity.charlie.name
        ]
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
        let updateTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
            self.flock.update(deltaTime: timer.timeInterval)
        }
        RunLoop.current.add(updateTimer, forMode: .common)
        self.updateTimer = updateTimer
        
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

        updateTimer?.invalidate()
    }
}
