//
//  Extensions.swift
//  Scheduler
//
//  Created by James Chang on 2023/7/28.
//

import SwiftUI
import Foundation
import UserNotifications

// Material Button

struct MaterialButtonStyle: ButtonStyle {

    @State var radius: CGFloat = 7
    @State var hover = false
    @State var text = ""

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: radius).opacity(hover ? 0.08 : 0).shadow(radius: 2)
                    Text(text).opacity(configuration.isPressed ? 0.9 : hover ? 0.5 : 0)
                }
            )
            .onHover { hovering in
                hover = hovering
            }
            .animation(.smooth(duration: 0.1), value: hover)
    }
}

// GLASS

struct GlassModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let cornerRadius: (CGFloat, CGFloat)
    let fill: (Color, Color)
    let opacity: (CGFloat, CGFloat)
    let shadowRadius: (CGFloat, CGFloat)

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: colorScheme == .light ? cornerRadius.0 : cornerRadius.1)
                    .fill(colorScheme == .light ? fill.0 : fill.1)
                    .opacity(colorScheme == .light ? opacity.0 : opacity.1)
                    .shadow(radius: colorScheme == .light ? shadowRadius.0 : shadowRadius.1, y: colorScheme == .light ? 2 : 0)
            }
            .overlay {
                RoundedRectangle(cornerRadius: colorScheme == .light ? cornerRadius.0 : cornerRadius.1)
                    .stroke(.primary.opacity(0.7), lineWidth: 1)
                    .opacity(colorScheme == .light ? 0 : 0.15)
            }
            .padding(0.5)
            .overlay {
                RoundedRectangle(cornerRadius: colorScheme == .light ? cornerRadius.0 : cornerRadius.1)
                    .stroke(.black, lineWidth: 0.5)
                    .opacity(colorScheme == .light ? 0 : 0.2)
            }
    }
}

extension View {
#if os(iOS)
    func glass(cornerRadius: (CGFloat, CGFloat) = (10.0, 10.0), fill: (Color, Color) = (Color.white, Color(UIColor.darkGray)), opacity: (CGFloat, CGFloat) = (0.3, 0.3), shadowRadius: (CGFloat, CGFloat) = (3.0, 8.0)) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius, fill: fill, opacity: opacity, shadowRadius: shadowRadius))
    }
#elseif os(macOS)
    func glass(cornerRadius: (CGFloat, CGFloat) = (10.0, 10.0), fill: (Color, Color) = (Color.white, Color(NSColor.darkGray)), opacity: (CGFloat, CGFloat) = (0.3, 0.3), shadowRadius: (CGFloat, CGFloat) = (3.0, 8.0)) -> some View {
        modifier(GlassModifier(cornerRadius: cornerRadius, fill: fill, opacity: opacity, shadowRadius: shadowRadius))
    }
#endif
}

func sendNotifications(title: String, subtitle: String, hour: Int, minute: Int, second: Int, repeats: Bool) {
    let notificationContent = UNMutableNotificationContent()
    notificationContent.title = title
    notificationContent.subtitle = subtitle

    let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour, minute: minute, second: second), repeats: repeats)
    let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: notificationTrigger)

    UNUserNotificationCenter.current().add(notificationRequest)
}


















extension View {
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationView {
            ZStack {
                self
//                    .navigationBarTitle("")
//                    .navigationBarHidden(true)
                NavigationLink {
                    view
//                        .navigationBarTitle("")
//                        .navigationBarHidden(true)
                } label: {
                    Text("Test")
                }

//                NavigationLink {
//                    view
//                } label: {
//                    <#code#>
//                }
//
//                navigationDestination(isPresented: binding) {
//                    view
//                                            .navigationBarTitle("")
//                                            .navigationBarHidden(true)
//                }
//                NavigationLink(
//                    destination: view
//                        .navigationBarTitle("")
//                        .navigationBarHidden(true),
//                    isActive: binding
//                ) {
//                    EmptyView()
//                }
            }
        }
    }
}

// Simple preference that observes a CGFloat.
struct ScrollViewOffsetPreferenceKey: PreferenceKey {
  static var defaultValue = CGFloat.zero

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value += nextValue()
  }
}

// A ScrollView wrapper that tracks scroll offset changes.
struct ObservableScrollView<Content>: View where Content : View {
  @Namespace var scrollSpace

  @Binding var scrollOffset: CGFloat
  let content: (ScrollViewProxy) -> Content

  init(scrollOffset: Binding<CGFloat>,
       @ViewBuilder content: @escaping (ScrollViewProxy) -> Content) {
    _scrollOffset = scrollOffset
    self.content = content
  }

  var body: some View {
    ScrollView {
      ScrollViewReader { proxy in
        content(proxy)
          .background(GeometryReader { geo in
              let offset = -geo.frame(in: .named(scrollSpace)).minY
              Color.clear
                .preference(key: ScrollViewOffsetPreferenceKey.self,value: offset)
          })
      }
    }
    .coordinateSpace(name: scrollSpace)
    .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
      scrollOffset = value
    }
  }
}

extension Binding {
    func onUpdate(_ closure: @escaping () -> Void) -> Binding<Value> {
        Binding(get: {
            wrappedValue
        }, set: { newValue in
            wrappedValue = newValue
            closure()
        })
    }
}

struct ModernBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var radius: CGFloat = 9
    
    var body: some View {
        Group {
            if colorScheme == .light {
                Color.white.opacity(0.8)
                    .mask(RoundedRectangle(cornerRadius: radius, style: .continuous))
                    .shadow(color: .black.opacity(0.15), radius: 2.75, y: 1)
            }
            else {
                Color.gray.opacity(0.25)
                    .mask(RoundedRectangle(cornerRadius: radius, style: .continuous))
                    .shadow(radius: 2.75, y: 1)
            }
        }
    }
}

struct ModernButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    @State var radius: CGFloat = 7
    @State var showOpaqueBackground = true
    @State var showTranslucentBackground = false
    @State var showHover = false
    @State var showBorder = false
    
    @State var onHover = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background {
                Group {
                    if showOpaqueBackground {
                        if colorScheme == .light {
                            Color.white.opacity(0.8)
                                .mask(RoundedRectangle(cornerRadius: radius, style: .continuous))
                                .shadow(color: .white, radius: 0.75, y: -0.5)
                            Color.white.opacity(0.9)
                                .mask(RoundedRectangle(cornerRadius: radius, style: .continuous))
                                .shadow(color: .black.opacity(0.25), radius: 1.25, y: 0.5)
                        }
                        else {
                            Color.gray.opacity(0.3)
                                .mask(RoundedRectangle(cornerRadius: radius, style: .continuous))
                                .shadow(color: .black.opacity(0.5), radius: 2, y: 1)
                        }
                    }
                    else if showTranslucentBackground {
                        Color.primary.opacity(0.04).mask(RoundedRectangle(cornerRadius: radius, style: .continuous))
                    }
                    if showHover && onHover {
                        Color.primary.opacity(0.04).mask(RoundedRectangle(cornerRadius: radius, style: .continuous))
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(lineWidth: 1)
                    .opacity(showBorder ? 0.1 : 0)
            }
            .onHover { hover in
                onHover = hover
            }
        #if os(iOS)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
        #elseif os(macOS)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.smooth(duration: 0.2), value: configuration.isPressed)
        #endif
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6))
            .frame(height: 30)
            .background {
                ModernBackground(radius: 7)
            }
    }
}

struct Note: Codable, Identifiable, Hashable {
    let id: String
    let dateCreated: Date
    var dateModified: Date
    var title: String
    var content: String
}

struct BlockNote: Codable, Identifiable, Hashable {
    let id: String
    var note: String
    let date: Date
    var blockOfDay: Int
}

enum Theme: String {
    case system
    case light
    case dark
}

enum DayType: String {
    case weekend
    case holiday
}

#if os(macOS)

struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

struct VisualEffectView: NSViewRepresentable {
    func makeNSView(context: Self.Context) -> NSView {
        let test = NSVisualEffectView()
        test.state = NSVisualEffectView.State.active
        // this is this state which says transparent all of the time
        return test
    }
    
   func updateNSView(_ nsView: NSView, context: Context) { }
}

extension NSDatePicker {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
    
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            isBezeled = false
            isBordered = false
            drawsBackground = true
        }
    }
}

extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear
            drawsBackground = true
        }
    }
}
#endif

func formatDate(date: Date, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.setLocalizedDateFormatFromTemplate(format)
    return dateFormatter.string(from: date)
}

func presetFirstDayOfSchool() -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    return dateFormatter.date(from: "2025-08-12")!
    
    ///
    /// # 24-25 School Year Preset
    ///
    
//    return dateFormatter.date(from: "2024-08-13")!
}

func presetBreakDays() -> [Date] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let dateStringArray = [
        "2025-08-12",
        "2025-09-02",
        "2025-09-09",
        "2025-09-15",
        "2025-09-29",
        "2025-09-30",
        "2025-10-01",
        "2025-10-02",
        "2025-10-03",
        "2025-10-06",
        "2025-10-31",
        "2025-11-28",
        "2025-12-18",
        "2025-12-19",
        "2025-12-22",
        "2025-12-23",
        "2025-12-24",
        "2025-12-25",
        "2025-12-26",
        "2025-12-29",
        "2025-12-30",
        "2025-12-31",
        "2026-01-01",
        "2026-01-02",
        "2026-01-22",
        "2026-01-23",
        "2026-02-12",
        "2026-02-13",
        "2026-02-16",
        "2026-02-17",
        "2026-02-18",
        "2026-02-19",
        "2026-02-20",
        "2026-02-23",
        "2026-03-13",
        "2026-03-30",
        "2026-03-31",
        "2026-04-01",
        "2026-04-02",
        "2026-04-03",
        "2026-04-20",
        "2026-05-01",
        "2026-05-04",
    ]
    
    ///
    /// # 24-25 School Year Break Days
    ///
    
//    let dateStringArray = [
//        "2024-08-13",
//        "2024-09-16",
//        "2024-09-16",
//        "2024-09-17",
//        "2024-09-30",
//        "2024-10-01",
//        "2024-10-02",
//        "2024-10-03",
//        "2024-10-04",
//        "2024-10-15",
//        "2024-11-07",
//        "2024-11-08",
//        "2024-11-29",
//        "2024-12-19",
//        "2024-12-20",
//        "2024-12-23",
//        "2024-12-24",
//        "2024-12-25",
//        "2024-12-26",
//        "2024-12-27",
//        "2024-12-30",
//        "2024-12-31",
//        "2025-01-01",
//        "2025-01-02",
//        "2025-01-03",
//        "2025-01-27",
//        "2025-01-28",
//        "2025-01-29",
//        "2025-01-30",
//        "2025-01-31",
//        "2025-02-03",
//        "2025-02-04",
//        "2025-02-27",
//        "2025-02-28",
//        "2025-03-20",
//        "2025-03-21",
//        "2025-03-31",
//        "2025-04-01",
//        "2025-04-02",
//        "2025-04-03",
//        "2025-04-04",
//        "2025-04-14",
//        "2025-05-01",
//        "2025-05-02",
//        "2025-05-30",
//    ]

    ///
    /// # 23-24 School Year Break Days
    ///

//    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
//    let dateStringArray = [
//        "2023-08-13 16:00:00 +0000",
//        "2023-09-28 16:00:00 +0000",
//        "2023-10-01 16:00:00 +0000",
//        "2023-10-02 16:00:00 +0000",
//        "2023-10-03 16:00:00 +0000",
//        "2023-10-04 16:00:00 +0000",
//        "2023-10-05 16:00:00 +0000",
//        "2023-11-09 16:00:00 +0000",
//        "2023-11-23 16:00:00 +0000",
//        "2023-12-07 16:00:00 +0000",
//        "2023-12-10 16:00:00 +0000",
//        "2023-12-11 16:00:00 +0000",
//        "2023-12-12 16:00:00 +0000",
//        "2023-12-13 16:00:00 +0000",
//        "2023-12-14 16:00:00 +0000",
//        "2023-12-17 16:00:00 +0000",
//        "2023-12-18 16:00:00 +0000",
//        "2023-12-19 16:00:00 +0000",
//        "2023-12-20 16:00:00 +0000",
//        "2023-12-21 16:00:00 +0000",
//        "2023-12-24 16:00:00 +0000",
//        "2023-12-25 16:00:00 +0000",
//        "2023-12-26 16:00:00 +0000",
//        "2023-12-27 16:00:00 +0000",
//        "2023-12-28 16:00:00 +0000",
//        "2023-12-31 16:00:00 +0000",
//        "2024-01-01 16:00:00 +0000",
//        "2024-01-02 16:00:00 +0000",
//        "2024-02-07 16:00:00 +0000",
//        "2024-02-08 16:00:00 +0000",
//        "2024-02-11 16:00:00 +0000",
//        "2024-02-12 16:00:00 +0000",
//        "2024-02-13 16:00:00 +0000",
//        "2024-02-14 16:00:00 +0000",
//        "2024-02-15 16:00:00 +0000",
//        "2024-02-18 16:00:00 +0000",
//        "2024-03-07 16:00:00 +0000",
//        "2024-03-31 16:00:00 +0000",
//        "2024-04-01 16:00:00 +0000",
//        "2024-04-02 16:00:00 +0000",
//        "2024-04-03 16:00:00 +0000",
//        "2024-04-04 16:00:00 +0000",
//        "2024-04-30 16:00:00 +0000",
//        "2024-06-09 16:00:00 +0000"
//    ]
    
    return dateStringArray.compactMap { dateString in
        dateFormatter.date(from: dateString)
    }
}

// @retroactive stuff
extension Date: @retroactive RawRepresentable {
    private static let formatter = ISO8601DateFormatter()

    public var rawValue: String {
        Date.formatter.string(from: self)
    }

    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}
// I added this @retroactive symbol just so that the warning error goes away; it really just does nothing 08/10/2025
extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

// same thing about @retroactive
extension Color: @retroactive RawRepresentable {

    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .gray
            return
        }
        do{
#if os(iOS) || os(visionOS)
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? .gray
#elseif os(macOS)
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) ?? .gray
#endif
            self = Color(color)
        } catch {
            self = .gray
        }
    }

    public var rawValue: String {
        do{
#if os(iOS) || os(visionOS)
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false) as Data
#elseif os(macOS)
            let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self), requiringSecureCoding: false) as Data
#endif

            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}

extension Date {
    var onlyDate: Date? {
        get {
            let calender = Calendar.current
            var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = NSTimeZone.system
            return calender.date(from: dateComponents)
        }
    }
//    var onlyDate: Date {
//        return Calendar.current.startOfDay(for: Date.)
//    }
    static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
}
