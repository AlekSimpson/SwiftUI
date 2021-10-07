//
//  Application.swift
//
//
//  Created by Alsey Coleman Miller on 12/12/19.
//

import Foundation
import CSDL2
import SDL
import OpenSwiftUI

//MARK: This file handles application runtime operations (window loop, events, etc)

/// SwiftUI Application singleton
public final class Application<V: View> {
    
    // MARK: - Properties
    public var view: V

    internal private(set) var isRunning = false
    
    public private(set) var windows = [Window]()
    
    // MARK: - Initialization

    public init(_ _view: V) {
        self.view = _view 

        do
        {
            try run()
        } catch 
        {
            print("Shaka when the walls fell (App Init Error)")
        }
    }

    // MARK: - Methods
    
    /// Starts the application's main run loop.
    public func run() throws {

        print("Initialization Successful!")

        let didLaunch: (() throws -> (Window)) = {
            return try Window(rootView: ConcreteViewRepresentable(), title: "", frame: (x: .centered, y: .centered, width: 640, height: 480))
        }

        isRunning = true
        defer { isRunning = false }
        
        assert(Thread.current.isMainThread, "Should only be called from main thread")
        
        try SDL.initialize(subSystems: [.video])
        defer { SDL.quit() }
        
        var window = try didLaunch() // window

        windows.append(window)
        
        let runloop = RunLoop.current
        
        // var sdlEvent = SDL_Event()
        
        // var events = [Event]()
        
        while isRunning {
            
            let startTime = SDL_GetTicks()
            let frameStart = Date()
            
            // poll events
            var maximumFramesPerSecond = 1
            for window in windows {
                let framesPerSecond = try window.window.displayMode().refreshRate
                if framesPerSecond > maximumFramesPerSecond {
                    maximumFramesPerSecond = framesPerSecond
                }
            }
            
            let maximumFrameTime = UInt32(1000 / maximumFramesPerSecond)
            
            var shouldPoll = true
            while SDL_GetTicks() - startTime < maximumFrameTime, shouldPoll {
                // shouldPoll = SDL_PollEvent(&sdlEvent) != 0
                // if let event = Event(sdlEvent) {
                //     events.append(event)
                // }
            }
            // events.forEach { send(event: $0) }
            // events.removeAll(keepingCapacity: true)
            
            // run main loop
            let maximumFrameDuration = 1.0 / TimeInterval(maximumFramesPerSecond)
            runloop.run(mode: .default, before: frameStart + maximumFrameDuration)
            
            // render
            for window in windows {
                try window.render(view: view)
            }
            
            // sleep to save energy
            let frameDuration = SDL_GetTicks() - startTime
            if frameDuration < maximumFrameTime {
                SDL_Delay(maximumFrameTime - frameDuration) // sleep for remainder of frame
            }
        }
    }
    
    public func quit() {
        
        self.isRunning = false
    }
    
    // internal func send(event: Event) {
        
    //     switch event {
    //     case .quit:
    //         quit()
    //     case let .window(windowEvent):
    //         let window = self.window(for: windowEvent.window)
    //         window.event(event)
    //     case let .drop(dropEvent):
    //         let window = self.window(for: dropEvent.window)
    //         window.event(event)
    //     case let .mouse(mouseEvent):
    //         let window = self.window(for: mouseEvent.window)
    //         window.event(event)
    //     }
    // }
    
    internal func window(for identifier: UInt) -> Window {
        
        guard let window = windows.first(where: { $0.identifier == identifier })
            else { fatalError("Invalid window identifier \(identifier)") }
        
        return window
    }
}