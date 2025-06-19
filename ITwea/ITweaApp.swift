//
//  ITweaApp.swift
//  ITwea - Twisted Tea Simulation
//
//  Created by Jess Cadena on 6/19/25.
//

import SwiftUI

@main
struct ITweaApp: App {
    init() {
        #if DEBUG
        // Simple InjectionIII setup for App Store version
        if let injectionPath = "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle",
           let bundle = Bundle(path: injectionPath) {
            bundle.load()
            print("✅ InjectionIII loaded successfully!")
        } else {
            print("❌ InjectionIII not found. Make sure the app is installed and running.")
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
