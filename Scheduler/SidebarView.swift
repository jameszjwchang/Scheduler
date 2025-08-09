//
//  SidebarView.swift
//  Scheduler
//
//  Created by Hawkanesson on 11/22/22.
//

import SwiftUI

struct SidebarRow: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    
    @State var title: String
    @State var img: String
    var badge: Binding<[Item]>?
    
    @Binding var selection: String
    
    @State private var isHover = false
    @State private var isPressed = false
    @State var lineLimit = 1
    
    var body: some View {
        HStack {
            Image(systemName: img)
                .foregroundStyle(title == selection ? Color(nsColor: .windowBackgroundColor) : chosenTint)
                .frame(width: 20)
            Text(title)
                .foregroundStyle(title == selection ? Color(nsColor: .windowBackgroundColor) : .primary)
                .lineLimit(lineLimit)
            Spacer(minLength: 0)
            if badge != nil {
                if badge!.count != 0 {
                    Text("\(badge!.count)")
                        .foregroundStyle(title == selection ? Color(nsColor: .windowBackgroundColor).opacity(0.8) : .primary)
                        .fontWeight(.bold)
                        .font(.caption)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .foregroundStyle(.primary.opacity(0.05))
                        )
                }
            }
        }
        .frame(height: 16*CGFloat(lineLimit))
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .animation(.easeInOut(duration: 0.04), value: selection)
        .animation(nil, value: selection == title)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .foregroundStyle(title == selection ? chosenTint : .clear)
                    .opacity(0.9)
                    .shadow(color: chosenTint, radius: 2)
                    .animation(.smooth(duration: 0.05), value: selection)
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .foregroundStyle(.primary.opacity(isPressed ? 0.1 : (isHover ? 0.05 : 0)))
                    .shadow(radius: 2)
                    .animation(.smooth(duration: 0.05), value: selection)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.smooth(duration: 0.2)) {
                selection = title
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    withAnimation(.smooth(duration: 0.1)) {
                        isPressed = true
                    }
                })
                .onEnded({ _ in
                    withAnimation(.smooth(duration: 0.1)) {
                        isPressed = false
                    }
                })
        )
        .onHover { hover in
            withAnimation(.smooth(duration: 0.2)) {
                isHover = hover
            }
        }
    }
}

struct SidebarView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("TasksList") var TasksList: [Item] = []
    @AppStorage("Completed") var Completed: [Item] = []
    
    @Binding var selection: String
    @Binding var backgroundOpacity: Double
    @Binding var appMode: String

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    SidebarRow(title: "Schedule", img: "calendar.day.timeline.left", selection: $selection)
                    SidebarRow(title: "Calendar", img: "calendar", selection: $selection)
                    Divider()
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                    if appMode == "teacher" {
                        HStack {
                            Text("Teacher Utilities")
                                .foregroundStyle(.secondary)
                                .fontWeight(.bold)
                                .font(.subheadline)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        
                        SidebarRow(title: "Teacher Utilities", img: "bolt", selection: $selection, lineLimit: 2)
                            .transition(AnyTransition.opacity.combined(with: .push(from: .bottom)))
                        Divider()
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                    }
                    HStack {
                        Text("Tasks")
                            .foregroundStyle(.secondary)
                            .fontWeight(.bold)
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    SidebarRow(title: "Tasks", img: "pencil.line", badge: $TasksList, selection: $selection)
                    Divider()
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                    SidebarRow(title: "Notes", img: "square.and.pencil", selection: $selection)
                    SidebarRow(title: "About", img: "info.circle", selection: $selection)
                }
                .padding(8)
                Spacer()
            }
            .mask(
                VStack(spacing: 0) {
                    LinearGradient(colors: [.black.opacity(0), .black], startPoint: .top, endPoint: .bottom)
                        .frame(height: 8)
                    Rectangle().foregroundStyle(.black)
                    LinearGradient(colors: [.black, .black.opacity(0)], startPoint: .top, endPoint: .bottom)
                        .frame(height: 8)
                }
            )
            HStack {
                Button{
                    if let window = NSApplication.shared.windows.first {
                        let initialSize = CGSize(width: 360, height: 360)
                        var frame = window.frame
                        frame.size = initialSize
                        if let screen = window.screen {
                            let screenFrame = screen.visibleFrame
                            frame.origin.x = screenFrame.origin.x + (screenFrame.width - frame.width) / 2
                            frame.origin.y = screenFrame.origin.y + (screenFrame.height - frame.height) / 2
                        }
                        window.setFrame(frame, display: true, animate: true)
                    }
                } label: {
                    Image(systemName: "macwindow")
                        .font(.system(size: 8))
                        .padding(6)
                }
                .frame(width: 32, height: 28)
                .help("Small Window Size")
                Button {
                    if let window = NSApplication.shared.windows.first {
                        let initialSize = CGSize(width: 660, height: 660)
                        var frame = window.frame
                        frame.size = initialSize
                        if let screen = window.screen {
                            let screenFrame = screen.visibleFrame
                            frame.origin.x = screenFrame.origin.x + (screenFrame.width - frame.width) / 2
                            frame.origin.y = screenFrame.origin.y + (screenFrame.height - frame.height) / 2
                        }
                        window.setFrame(frame, display: true, animate: true)
                    }
                } label: {
                    Image(systemName: "macwindow")
                        .font(.system(size: 12))
                        .padding(6)
                }
                .frame(width: 32, height: 28)
                .help("Medium/Default Window Size")
                .offset(x: -3)
                Button {
                    if let window = NSApplication.shared.windows.first {
                        let screenSize = NSScreen.main?.frame.size ?? .zero
                        let initialSize = CGSize(width: screenSize.width, height: screenSize.height)
                        var frame = window.frame
                        frame.size = initialSize
                        if let screen = window.screen {
                            let screenFrame = screen.visibleFrame
                            frame.origin.x = screenFrame.origin.x + (screenFrame.width - frame.width) / 2
                            frame.origin.y = screenFrame.origin.y + (screenFrame.height - frame.height) / 2
                        }
                        window.setFrame(frame, display: true, animate: true)
                    }
                } label: {
                    Image(systemName: "macwindow")
                        .font(.system(size: 16))
                        .padding(6)
                }
                .frame(width: 32, height: 28)
                .help("Large Window Size")
            }
            
            .buttonStyle(ModernButtonStyle(showOpaqueBackground: false, showHover: true))
            .padding(2)
            .frame(width: 120)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .opacity(0.05)
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 8)
        }
        .glass(cornerRadius: (10.0, 10.0))
        .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 0))
        .frame(width: 142)
    }
}

struct ContentPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
