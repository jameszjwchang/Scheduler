//
//  SchedulerApp.swift
//  Scheduler
//
//  Created by James Chang on 2023/3/5.
//

import SwiftUI
import Foundation
import SwiftUIIntrospect

//import SwiftData

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillBecomeActive(_ notification: Notification) {
        NSApp.windows.first?.makeKeyAndOrderFront(self)
    }
}
#endif

@main
struct SchedulerApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    @AppStorage("colorScheme") var colorScheme: Theme = .system
    @AppStorage("MenuBarToggle") var MenuBarToggle = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .fontDesign(.rounded)
                .preferredColorScheme(colorScheme == .system ? .none : (colorScheme == .light ? .light : .dark))
#if os(macOS)
                .frame(minWidth: 320, minHeight: 200)
#endif
        }
        #if os(macOS)
        .defaultSize(width: 660, height: 660)
        #endif
//        .modelContainer(for: BreakDay.self)
        
#if os(macOS)
        MenuBarExtra(isInserted: $MenuBarToggle) {
            MenuBarView()
        } label: {
            let image: NSImage = {
                   let ratio = $0.size.height / $0.size.width
                   $0.size.height = 21
                   $0.size.width = 21 / ratio
                   return $0
            }(NSImage(named: "AppIcon")!)

            Image(nsImage: image)
        }
                .menuBarExtraStyle(.window)
#endif
        
        #if os(macOS)
        Settings {
            SettingsView()
                .fontDesign(.rounded)
                .preferredColorScheme(colorScheme == .system ? nil : (colorScheme == .light ? .light : .dark))
                .frame(width: 480, height: 336)
//                .introspect(.window, on: .macOS(.v13, .v14)) { window in
//                    var frame = window.frame
//                    window.setFrame(frame, display: true, animate: true)
//                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            SidebarCommands()
        }
        #endif
    }
}

//enum BreakDayType: Codable {
//    case weekend
//    case holiday
//}
//
//@Model
//class BreakDay {
//    var breakdate: Date
//    var breaktype: BreakDayType
//    
//    init(breakdate: Date, breaktype: BreakDayType) {
//        self.breakdate = breakdate
//        self.breaktype = breaktype
//    }
//}
