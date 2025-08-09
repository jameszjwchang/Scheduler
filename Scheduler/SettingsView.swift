//
//  SettingsView.swift
//  Scheduler
//
//  Created by Hawkanesson on 11/3/22.
//

import Foundation
import SwiftUI

struct ProfileSettingsView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("firstDayOfSchool") var SchoolyearStartingDay: Date = Date().onlyDate!
    
    #if os(macOS)
        @AppStorage("MenuBarToggle") var MenuBarToggle = true
    
    @State var DatePopover = false
    #endif
    @AppStorage("TasksList") var TasksList: [Item] = []
    @AppStorage("SortTasks") var SortTasks = true
//    @AppStorage("SortEvents") var SortEvents = true
    
    @AppStorage("AppMode") var AppMode = "student"
    @AppStorage("SchoolLevel") var schoolLevel = "HS"
    @State private var pickerAppMode = "student"
    
    @State private var teacherModePasswordView = false
    @State private var input = ""
    @State private var wrongPassword = false
    
    var body: some View {
        Form {
            #if os(macOS)
            Section {
                Toggle(isOn: $MenuBarToggle) {
                    Text("Menu Bar:")
                }
                .toggleStyle(SwitchToggleStyle(tint: chosenTint))
            }
            #endif

            Section {
                Picker("School Level:", selection: $schoolLevel) {
                    Text("High School").tag("HS")
                    Text("Middle School").tag("MS")
                  
                }
                Picker("App Mode:", selection: $pickerAppMode.animation(.snappy(duration: 0.35, extraBounce: 0.2))) {
                    Text("Student").tag("student")
                    Text("Teacher").tag("teacher")
                }
                .onChange(of: pickerAppMode) {
                    if pickerAppMode == "teacher" && AppMode != "teacher" {
                        teacherModePasswordView = true
                    }
                    else if pickerAppMode == "student" {
                        DispatchQueue.main.async {
                            withAnimation(.snappy(duration: 0.35, extraBounce: 0.2)) {
                                AppMode = "student"
                            }
                        }
                    }
                }
                .sheet(isPresented: $teacherModePasswordView) {
                    let password = "teachersareawesome"
                    
                    VStack {
                        SecureField("test", text: $input, prompt: Text("Please enter the password here.").fontWeight(.bold))
                            .textFieldStyle(ModernTextFieldStyle())
                            .textFieldStyle(.plain)
                        HStack {
                            Button {
                                pickerAppMode = "student"
                                teacherModePasswordView = false
                            } label: {
                                Text("Cancel")
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                            }
                            Button {
                                if input == password {
                                    teacherModePasswordView = false
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                        withAnimation(.snappy(duration: 0.35, extraBounce: 0.3)) {
                                            AppMode = "teacher"
                                        }
                                    })
                                }
                                else {
                                    wrongPassword = true
                                }
                            } label: {
                                Text("Unlock")
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                            }
                            .keyboardShortcut(.return, modifiers: [])
                        }
                        .buttonStyle(ModernButtonStyle(showOpaqueBackground: false, showTranslucentBackground: true, showHover: true))
                        if wrongPassword {
                            Text("Wrong password!")
                                .foregroundStyle(.red)
                                .fontWeight(.bold)
                                .transition(.opacity)
                        }
                    }
                    .onChange(of: wrongPassword) {
                        if wrongPassword {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                wrongPassword = false
                            }
                        }
                    }
                    .padding()
                    .frame(minWidth: 264, minHeight: 120)
                    #if os(macOS)
                    .background(VisualEffectView())
                    #endif
                    .onAppear {
                        input = ""
                    }
                }
                .onAppear {
                    pickerAppMode = AppMode
                }
            }
            Section {
                Toggle(isOn: $SortTasks) {
                    Text("Sort Tasks by Date")
                }
                .toggleStyle(SwitchToggleStyle(tint: chosenTint))
            }
            .onChange(of: SortTasks) {
                if SortTasks {
                    TasksList.sort {
                        $0.due < $1.due
                    }
                }
            }
        }
        .formStyle(GroupedFormStyle())
        #if os(iOS)
        .shadow(color: .primary.opacity(0.08), radius: 5)
        .background(colorScheme == .light ? Color(red: 242/255, green: 242/255, blue: 245/255) : .black)
        .scrollContentBackground(.hidden)
        #endif
    }
}

struct AppearanceSettingsView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    @AppStorage("colorScheme") var colorScheme: Theme = .system
    @Environment(\.colorScheme) var colorMode
    
    @AppStorage("hueColor") var hueColor: Double = 0
    @AppStorage("brightnessLevel") var brightnessLevel: Double = 0
    
    var body: some View {
        Form {
            Section {
                VStack {
#if os(iOS)
                    HStack {
                        Text("Color:")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
#endif
                    
                    HStack {
                        Circle()
                            .fill(Color(hue: hueColor/360, saturation: 1, brightness: 1 - brightnessLevel/360))
                            .frame(width: 33, height: 33)
                            .shadow(color: .primary, radius: 2)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.6), lineWidth: 4)
                                    .frame(width: 29, height: 29)
                            )
#if os(macOS)
                        Text("Color:")
#endif
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 11)
                                .fill(LinearGradient(colors: [
                                    Color(hue: 0/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 1/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 2/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 3/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 4/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 5/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 6/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 7/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 8/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 9/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 10/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 11/12, saturation: 0.8, brightness: 1),
                                    Color(hue: 12/12, saturation: 0.8, brightness: 1)
                                ], startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: 279, height: 34)
                                .shadow(color: .primary, radius: 2)
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(.white.opacity(0.6), lineWidth: 4)
                                .frame(width: 275, height: 30)
                            HStack {
                                Slider(value: $hueColor.animation(.smooth), in: 0...360, step: 10)
                                    .labelsHidden()
                                    .frame(width: 265)
                                    .tint(chosenTint)
                                    .opacity(0.6)
                                    .onChange(of: hueColor) {
                                        withAnimation(.smooth) {
                                            chosenTint = Color(hue: hueColor/360, saturation: 0.8, brightness: 1 - brightnessLevel/360)
                                        }
                                    }
                            }
                        }
                    }
                }
                VStack {
                    #if os(iOS)
                    HStack {
                        Text("Brightness:")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    #endif
                    HStack {
                        Circle()
                            .fill(Color(hue: 0, saturation: 0, brightness: 1 - brightnessLevel/360))
                            .frame(width: 33, height: 33)
                            .shadow(color: .primary, radius: 2)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.6), lineWidth: 4)
                                    .frame(width: 29, height: 29)
                                    .shadow(color: .gray, radius: 1)
                            )
#if os(macOS)
                        Text("Brightness:")
#endif
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 11)
                                .fill(LinearGradient(colors: [
                                    Color(hue: 0, saturation: 0, brightness: 12/12),
                                    Color(hue: 0, saturation: 0, brightness: 11/12),
                                    Color(hue: 0, saturation: 0, brightness: 10/12),
                                    Color(hue: 0, saturation: 0, brightness: 9/12),
                                    Color(hue: 0, saturation: 0, brightness: 8/12),
                                    Color(hue: 0, saturation: 0, brightness: 7/12),
                                    Color(hue: 0, saturation: 0, brightness: 6/12),
                                    Color(hue: 0, saturation: 0, brightness: 5/12),
                                    Color(hue: 0, saturation: 0, brightness: 4/12),
                                    Color(hue: 0, saturation: 0, brightness: 3/12),
                                    Color(hue: 0, saturation: 0, brightness: 2/12),
                                    Color(hue: 0, saturation: 0, brightness: 1/12),
                                    Color(hue: 0, saturation: 0, brightness: 0/12)
                                ], startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: 279, height: 34)
                                .shadow(color: .primary, radius: 2)
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(.white.opacity(0.6), lineWidth: 4)
                                .frame(width: 275, height: 30)
                                .shadow(color: .gray, radius: 1)
                            HStack {
                                Slider(value: $brightnessLevel.animation(.smooth), in: 0...360, step: 10)
                                    .labelsHidden()
                                    .frame(width: 265)
                                    .tint(chosenTint)
                                    .opacity(0.6)
                                    .onChange(of: brightnessLevel) {
                                        withAnimation(.smooth) {
                                            chosenTint = Color(hue: hueColor/360, saturation: 0.8, brightness: 1 - brightnessLevel/360)
                                        }
                                    }
                            }
                        }
                    }
                }
            } header: {
                Text("Theme Color")
            }
            
            Section {
                HStack {
                    Circle()
                        .fill(colorMode == .light ? .white : .black)
                        .frame(width: 33, height: 33)
                        .shadow(color: .primary, radius: 2)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.6), lineWidth: 4)
                                .frame(width: 29, height: 29)
                                .shadow(color: .gray, radius: 1)
                        )
                    Picker("Color Mode:", selection: $colorScheme) {
                        Text("System").tag(Theme.system)
                        Divider()
                        Text("Light").tag(Theme.light)
                        Text("Dark").tag(Theme.dark)
                    }
                    .onChange(of: colorScheme) {
                        if colorScheme == .system {
                            if colorMode == .light {
                                colorScheme = .light
                                colorScheme = .system
                            }
                            else if colorMode == .dark {
                                colorScheme = .dark
                                colorScheme = .system
                            }
                        }
                    }
                }
            } footer: {
                #if os(macOS)
                Text("Note: When changing to \"System\", the colors might look a bit weird. Just close the settings window and it will be fine.")
                    .foregroundColor(.secondary)
                    .font(.system(size: 11))
                #endif
            }
        }
        .formStyle(GroupedFormStyle())
#if os(iOS)
        .shadow(color: .primary.opacity(0.08), radius: 5)
        .background(colorScheme == .light ? Color(red: 242/255, green: 242/255, blue: 245/255) : .black)
#endif
    }
}

//#if os(iOS)
struct AboutView: View {
    #if os(iOS)
    @Environment(\.colorScheme) var colorScheme
    #endif
    
    var body: some View {
        ScrollView {
            Text("About Scheduler")
                .font(.largeTitle)
            Text("""
             Hello! My name is James Chang, and I'm part of the class of 2026.

             I created Scheduler during my freshmen year to help me stay organized and remember which classes I have on each school day. Over time, it has evolved into a comprehensive tool for managing everything school-related.

             **Features of Scheduler**
             
             Class Schedules: Keep track of your daily classes.
             Assignments: Manage and track homework and projects.
             Reminders: Set reminders for important deadlines and events.
             Notes: Jot down important notes and ideas.
             
             **Contact**
             
             If you have any feedback or suggestions for Scheduler, feel free to contact me at my school email address:
             james01px2026@saschina.org

             **I hope that you will benefit from this app as much as I do!**
             
             
             """)
            .multilineTextAlignment(.center)
            .lineSpacing(12)
            #if os(iOS)
            .padding(32)
            #elseif os(macOS)
            .padding(48)
            #endif
        }
#if os(iOS)
        .background(colorScheme == .light ? Color(red: 242/255, green: 242/255, blue: 245/255) : .black)
#endif
        #if os(macOS)
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("About")
        #endif
    }
}

struct SettingsView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    @Environment(\.colorScheme) var colorScheme
    
    #if os(macOS)
    @State private var window: NSWindow?
    #endif
    
    @AppStorage("AppMode") var AppMode = "student"
    @State private var pickerAppMode = "student"
    
    @State private var teacherModePasswordView = false
    @State private var input = ""
    @State private var wrongPassword = false
    
    var body: some View {
#if os(iOS)
        List {
            Section {
                NavigationLink(destination: ProfileSettingsView()) {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            }
            Section {
                NavigationLink(destination: BreakDaysEditingView()) {
                    Label("Break Days", systemImage: "calendar.badge.plus")
                }
                NavigationLink(destination: AppearanceSettingsView()) {
                    Label("Appearance", systemImage: "paintpalette")
                }
            }
            Section {
                NavigationLink(destination: AboutView()) {
                    Label("About", systemImage: "info.circle")
                }
            }
        }
        .shadow(color: .primary.opacity(0.08), radius: 5)
        .navigationTitle("Settings")
        .scrollContentBackground(.hidden)
        .background(colorScheme == .light ? Color(red: 242/255, green: 242/255, blue: 245/255) : .black)
        .tint(chosenTint)
        .onAppear() {
                pickerAppMode = AppMode
        }
#elseif os(macOS)
        TabView {
            ProfileSettingsView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintpalette")
                }
        }
        .scrollContentBackground(.hidden)
        .tint(chosenTint)
        .background(WindowAccessor(window: $window))
        .background(
            ZStack {
                VisualEffectView().ignoresSafeArea(.all)
                if colorScheme == .light {
                    Color.white.opacity(0.5)
                    .ignoresSafeArea(.all)
                }
                else {
                    Color.black.opacity(0.3)
                    .ignoresSafeArea(.all)
                }
            }
        )
        .onChange(of: window) {
            window?.titlebarAppearsTransparent = true
            window?.backgroundColor = .controlBackgroundColor.withAlphaComponent(0.1)
        }
        #endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    
    static var previews: some View {
        BreakDaysEditingView()
    }
}


