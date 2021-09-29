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

public final class SDLView<view: View> {
    
    // MARK: - Properties

    public private(set) var subviews = [view?]()
    
    public private(set) var superview: view?
    
    public var alpha: Float = 1.0 {
        didSet {
            assert(alpha >= 0.0 && alpha <= 1.0, "Invalid alpha \(alpha)")
            //setNeedsDisplay()
        }
    }

    public var frame:CGRect?
    
    public var window: Window?
    
    // The root view in the hierarchy.
    private var rootSuperview: view {
        return self.rootSuperview 
    }
    
    internal var rootWindow: Window? {
        return window ?? self.rootWindow
    }
    
    // MARK: - Initialization
    
    public init(frame: CGRect = .zero) {
        self.frame = frame
    }
    
    // MARK: - Methods
    
    public func addSubview(_ view: view) {
        
        self.subviews.append(view)
        self.superview = view
    }
    
    public func removeFromSuperview() {
        
        guard let _ = self.superview, // _ = superview
            let index = self.subviews.firstIndex(where: { $0 as? SDLView<view> === self })
            else { return }
        
        self.subviews.remove(at: index)
    }
}

public protocol ViewRepresentable: View { // Inner
    
    typealias ViewType = SDLView<Self> 
    typealias Context = ViewRepresentableContext
    
    func makeView(context: Context) -> ViewType
    func updateView(_ view: ViewType, context: Context)
}

public extension ViewRepresentable {
    
    func load(context: Context) -> ViewType {
        let view = makeView(context: context)
        updateView(view, context: context)
        return view
    }
}

/*

MARK: OK SO ConcreteViewRepresentable NEEDS TO HAVE AN INITIALIZER THAT TAKES IN A TYPE View AND INITIALIZES THAT VIEW AS THE BODY AND AS AN SDLView
THIS IS BECAUSE THEN WE CAN PASS IN A REGUALR VIEW TO APPLICATION AND THAT VIEW CAN BE TURNED INTO A CONCRETE VIEW THAT THEN CAN SENT TO BE RENDERED BY THE APPLICAITON

*/

public struct ConcreteViewRepresentable: ViewRepresentable, View
{
    public var sdlview = SDLView<Self>() 
    public typealias Context = ViewRepresentableContext

    public var body: some View { Text("test") }

    public func makeView(context: Context) -> ViewType { return sdlview }
    public func updateView(_ view: ViewType, context: Context) {}
}

public struct ViewRepresentableContext {
    typealias Representable = ViewRepresentable
}