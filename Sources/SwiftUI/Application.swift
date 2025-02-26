//
//  Application.swift
//
//
//  Created by Alsey Coleman Miller on 12/12/19.
//

// import Foundation
import CSDL2
import SDL
import OpenSwiftUI

/*
MARK:
Application needs a generic paramter of type View that will be passed into window and thus into SDLView.
In the SwiftUI project I need to pass in the MainView as a generic paramter to an Application instance. 

SUB-MARK:
Might end up needing to make the View parameter an initialization paramter and not a generic parameter but that needs to know for sure. 

*/

/// SwiftUI Application singleton
public final class Application {
    
    // MARK: - Initialization
    
    public static let shared = Application()

    private init() { }
    
    // MARK: - Properties
    public typealias representable = ConcreteViewRepresentable
    
    public var didLaunch: (() throws -> (Window<representable>)) = {
        return try Window(rootView: ConcreteViewRepresentable(), title: "", frame: (x: .centered, y: .centered, width: 640, height: 480))
    }
    
    internal private(set) var isRunning = false
    
    public private(set) var windows = [Window<representable>]()
    
    // MARK: - Methods
    
    /// Starts the application's main run loop.
    public func run() throws {
        
        isRunning = true
        defer { isRunning = false }
        
        assert(Thread.current.isMainThread, "Should only be called from main thread")
        
        try SDL.initialize(subSystems: [.video])
        defer { SDL.quit() }
        
        var _ = try didLaunch() // window
        
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
            // for window in windows {
            //     try window.update()
            // }
            
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
    
    internal func window(for identifier: UInt) -> Window<representable> {
        
        guard let window = windows.first(where: { $0.identifier == identifier })
            else { fatalError("Invalid window identifier \(identifier)") }
        
        return window
    }
}
