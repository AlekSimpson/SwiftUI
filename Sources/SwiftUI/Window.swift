//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 12/12/19.
//

import Foundation
import CSDL2
import SDL
import OpenSwiftUI

//MARK: This file handles actually rendering the window and showing to the screen

/// Window for hosting SwiftUI views.
public final class Window {
    
    // MARK: - Properties
    
    public private(set) var rootView: ConcreteViewRepresentable
    
    internal let window: SDLWindow
    
    internal let renderer: SDLRenderer
    
    public var identifier: UInt {
        return window.identifier
    }
    
    public var size: Size {
        let size = window.size
        return Size(width: size.width, height: size.height)
    }
    
    /// Size of a window’s underlying drawable in pixels.
    public var nativeSize: Size {
        let size = window.drawableSize
        return Size(width: size.width, height: size.height)
    }
    
    /// UI scale in points.
    public var scale: Float { return Float(nativeSize.width) / Float(size.width) }
    
    internal private(set) var context = ViewRepresentableContext()
    
    // MARK: - Initialization
    public init(rootView: ConcreteViewRepresentable, title: String = "", frame: (x: SDLWindow.Position, y: SDLWindow.Position, width: Int, height: Int)) throws {
        self.window = try SDLWindow(
            title: title,
            frame: frame,
            options: [.allowRetina, .opengl, .resizable, .shown]
        )
        
        self.renderer = try SDLRenderer(window: window, options: [.accelerated])
        
        self.rootView = rootView
        
        // initialize underlying root view
        // let _ = rootView.load(context: context) // view
    }
    
    // MARK: - Methods
    
    internal func render<V: View>(view: V) throws {
        
        try renderer.setDrawColor(red: 0x00, green: 0x00, blue: 0x00, alpha: 0xFF)
        try renderer.clear()

        let surface = try SDLSurface(rgb: (0, 0, 0, 0), size: (width: 1, height: 1), depth: 32)
        let color = SDLColor(
            format: try SDLPixelFormat(format: .argb8888),
            red: 25, green: 50, blue: .max, alpha: .max / 2
        )
        try surface.fill(color: color)
        let surfaceTexture = try SDLTexture(renderer: renderer, surface: surface)
        try surfaceTexture.setBlendMode([.alpha])
        try renderer.copy(surfaceTexture, destination: SDL_Rect(x: 100, y: 100, w: 200, h: 200))

        // try render(view: view, origin: .zero)
        // try render(view: view)

        renderer.present()                                                                                                                                                                    
    }
}
