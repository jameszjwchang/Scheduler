//
//  ContentView.swift
//  Scheduler
//
//  Created by James Chang on 2023/3/5.
//

import Foundation
import SwiftUI
import UserNotifications
import SwiftUIIntrospect

struct ContentView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    @Environment(\.colorScheme) var colorMode
    
    @AppStorage("TasksList") var TasksList: [Item] = []
    
    #if os(iOS) || os(visionOS)
    @State var selectedTab = 1
    @FocusState private var isFocused: Bool
    #endif
    
    #if os(macOS)
    @State var backgroundOpacity: Double = 1
    @State private var window: NSWindow?
    @State var selection = "Schedule"
    @State var showSidebar = true
    #endif
    
    @AppStorage("AppMode") var AppMode = "student"
    @State private var pickerAppMode = "student"
    
    @State private var teacherModePasswordView = false
    @State private var input = ""
    @State private var wrongPassword = false
    
    @AppStorage("Onboard2.0") var Onboardy = true
    @State private var onboardView = false
    
    var body: some View {
        #if os(iOS) || os(visionOS)
        NavigationStack {
            TabView(selection: $selectedTab.onUpdate {
#if os(iOS)
                let impactHeavy = UIImpactFeedbackGenerator(style: .medium)
                impactHeavy.impactOccurred()
#endif
            }) {
                DashboardView()
                    .background(colorMode == .light ? Color(UIColor.systemGray6) : Color(hue: 0, saturation: 0, brightness: 15/255))
                    .tabItem {
                        Label("Dashboard", systemImage: "calendar.day.timeline.leading")
                    }
                    .tag(1)
                CalendarView()
                    .background(colorMode == .light ? Color(UIColor.systemGray6) : Color(hue: 0, saturation: 0, brightness: 15/255))
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(2)
                TasksView()
                    .background(colorMode == .light ? Color(UIColor.systemGray6) : Color(hue: 0, saturation: 0, brightness: 15/255))
                    .tabItem {
                        Label("Tasks", systemImage: "checklist")
                    }
                    .tag(3)
                NotesView()
                    .background(colorMode == .light ? Color(UIColor.systemGray6) : Color(hue: 0, saturation: 0, brightness: 15/255))
                    .tabItem {
                        Label("Notes", systemImage: "square.and.pencil")
                    }
                    .tag(4)
                SettingsView()
                    .background(colorMode == .light ? Color(UIColor.systemGray6) : Color(hue: 0, saturation: 0, brightness: 15/255))
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(5)
            }
            .navigationTitle(selectedTab == 5 ? "Settings" : "")
            
        }
        .tint(chosenTint)
        .onAppear() {
            UNUserNotificationCenter.current().setBadgeCount(TasksList.count)
//            UIApplication.shared.applicationIconBadgeNumber = TasksList.count
        }
        .onChange(of: TasksList.count) {
            UNUserNotificationCenter.current().setBadgeCount(TasksList.count)
//            UIApplication.shared.applicationIconBadgeNumber = TasksList.count
        }
        .onAppear(perform: requestNotifications)
        
#elseif os(macOS)
        VStack {
            if onboardView || Onboardy {
                
                OnboardView(onboardView: $onboardView)
                .toolbar {
                    Text("")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .navigationTitle("")
                .onAppear {
                        withAnimation(.snappy) {
                            backgroundOpacity = 1
                        }
                }
            }
            else {
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        if showSidebar {
                            SidebarView(selection: $selection, backgroundOpacity: $backgroundOpacity, appMode: $AppMode)
                                .transition(AnyTransition.move(edge: .leading))
                        }
                        Group {
                            if selection == "Schedule" {
                                DashboardView()
                            }
                            else if selection == "Calendar" {
                                CalendarView()
                            }
                            else if selection == "Notes" {
                                NotesView(backgroundOpacity: $backgroundOpacity)
                            }
                            else if selection == "About" {
                                AboutView()
                            }
                            else if selection == "Teacher Utilities" {
                                TeacherTools()
                            }
                            else {
                                if selection == "Tasks" {
                                    TasksView()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: geometry.size.width) {
                        withAnimation(.smooth(duration: 0.2)) {
                            showSidebar = geometry.size.width < 636 ? false :  true
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: ToolbarItemPlacement.navigation) {
                            Button(action: {
                                withAnimation(.smooth(duration: 0.2)) {
                                    showSidebar.toggle()
                                }
                            }, label: {
                                Image(systemName: "sidebar.leading")
                                    .font(.system(size: 17))
                                    .opacity(0.75)
                                    .frame(width: 33, height: 28)
                            })
                            .buttonStyle(ModernButtonStyle(showOpaqueBackground: false, showHover: true))
                            .offset(y: -1)
                        }
                        ToolbarItemGroup(placement: .automatic) {
                            Button {
                                withAnimation(.smooth) {
                                    onboardView = true
                                }
                            } label: {
                                Text("Setup")
                                    .padding(5)
                                    .opacity(0.75)
                            }
                            .buttonStyle(ModernButtonStyle(showOpaqueBackground: false, showHover: true, showBorder: true))
                            
                            if #available(macOS 14.0, *) {
                                SettingsLink {
                                    Image(systemName: "gear")
                                        .font(.system(size: 18))
                                        .padding(5)
                                        .opacity(0.75)
                                }
                                .buttonStyle(ModernButtonStyle(showOpaqueBackground: false, showHover: true))
                                .clipShape(Circle())
//                                .scaleEffect(2)
                            } else {
                                Button(action: {
                                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                                }) {
                                    Image(systemName: "gear")
                                        .opacity(0.75)
                                    
                                }
                                .clipShape(Circle())
                            }
                        }
                    }
                    .tint(chosenTint)
                    .onChange(of: selection) {
                        withAnimation(.snappy) {
                            backgroundOpacity = 1
                        }
                    }
                }
            }
        }
        .onAppear() {
            NSApplication.shared.dockTile.badgeLabel = (TasksList.count == 0 ? nil : String(TasksList.count))
            requestNotifications()
            sendNotifications()
        }
        .onChange(of: AppMode) {
            if AppMode != "teacher" {
                if selection == "Teacher Utilities" {
                    selection = "Schedule"
                }
            }
        }
        .onChange(of: TasksList.count) {
            NSApplication.shared.dockTile.badgeLabel = (TasksList.count == 0 ? nil : String(TasksList.count))
        }
        .background(WindowAccessor(window: $window))
        .onChange(of: window) {
            window?.titlebarAppearsTransparent = true
            window?.backgroundColor = .controlBackgroundColor.withAlphaComponent(0.1)
        }
        .background(
            ZStack {
                if colorMode == .light {
                    VisualEffectView()
//                    Color.white.opacity(0.2)
                    Color.white.opacity(0.1)
                }
                else {
                    VisualEffectView().glass()
                }
            }
                .opacity(backgroundOpacity)
                .ignoresSafeArea(.all)
                .padding(-8)
        )
#endif
    }
    
    func requestNotifications() {
        #if os(iOS) || os(visionOS)
        UNUserNotificationCenter.current().setBadgeCount(TasksList.count)
//        UIApplication.shared.applicationIconBadgeNumber = TasksList.count
        #endif
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
//            if success {
//                print("All set!")
//            } else if let error = error {
//                print(error.localizedDescription)
//            }
        }
    }
    
    func sendNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        let morningContent = UNMutableNotificationContent()
        morningContent.title = "Good Morning!"
        morningContent.subtitle = "You currently have \(TasksList.count) tasks to do. Remember to complete them all!"

        let morningTrigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: 8, minute: 0, second: 0), repeats: true)
        let morningRequest = UNNotificationRequest(identifier: "MorningMessage", content: morningContent, trigger: morningTrigger)

        UNUserNotificationCenter.current().add(morningRequest)
        
        let eveningContent = UNMutableNotificationContent()
        eveningContent.title = "Good Evening!"
        eveningContent.subtitle = "Remember to check for any events tomorrow. Good job on your work today!"

        let eveningTrigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: 18, minute: 0, second: 0), repeats: true)
        let eveningRequest = UNNotificationRequest(identifier: "EveningMessage", content: eveningContent, trigger: eveningTrigger)

        UNUserNotificationCenter.current().add(eveningRequest)
    }
}

struct PPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

