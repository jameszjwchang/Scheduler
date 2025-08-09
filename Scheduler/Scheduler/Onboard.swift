//
//  Onboard.swift
//  Scheduler
//
//  Created by James Chang on 12/30/23.
//

import SwiftUI
import WidgetKit

import SwiftData

struct CardPreferenceData: Equatable {
    let squareDate: Date
    let bounds: CGRect
}

struct CardPreferenceKey: PreferenceKey {
    typealias Value = [CardPreferenceData]
    
    static var defaultValue: [CardPreferenceData] = []
    
    static func reduce(value: inout [CardPreferenceData], nextValue: () -> [CardPreferenceData]) {
        value.append(contentsOf: nextValue())
    }
}

struct BreakDaysSelectingView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    @Environment(\.colorScheme) var colorScheme
    
//    @Environment(\.modelContext) var modelContext
    
    @State var currentMonth = 0
    @State var date = Date().onlyDate!
    @State private var showAlert = false
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    @AppStorage("BreakDays") var BreakDays: [Date] = []
    
    @AppStorage("breakDaysMode") var breakDaysMode = 0
    @State private var loadedPresetBreakDays: [Date] = presetBreakDays()
    
    @State private var cardsData: [CardPreferenceData] = []
    
    @State private var dragBegins = false
    @State private var appendQuestionMark = -1
    
    @AppStorage("firstDayOfSchool") var firstDayOfSchool: Date = Date().onlyDate!
    
    @State var DatePopover = false
    
    
    
//    @Query var CustomBreakDays: [BreakDay]
    
    
    
    var body: some View {
        VStack {
            #if os(iOS)
            HStack {
                Text("Break Days\nSelection Method:")
                    .fontWeight(.bold)
                Picker(selection: $breakDaysMode.animation()) {
                    Text("Auto (24-25 school year, updated 2024-7-31)").tag(0)
                    Divider()
                    Text("Manual").tag(1)
                } label: {}
            }
            .padding(.bottom, 32)
            #elseif os(macOS)
            VStack {
                Text("Break Days\nSelection Method:")
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Picker(selection: $breakDaysMode.animation()) {
                    Text("Auto (24-25 school year, updated 2024-7-31)").tag(0)
                    Divider()
                    Text("Manual").tag(1)
                } label: {}
            }
            #endif
            
            VStack {
                #if os(iOS)
                if breakDaysMode == 0 {
                    Text("First day of school: \(presetFirstDayOfSchool().formatted(date: .numeric, time: .omitted))")
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .opacity(0.08)
                        }
                }
                else {
                    DatePicker(selection: $firstDayOfSchool, displayedComponents: .date) {
                        Text("Select the first\nday of school:").bold()
                    }
                }
                #elseif os(macOS)
                Text("Select the first day of school:").bold()
                    .padding(.top, 48)
                    .multilineTextAlignment(.center)
                Button(action: {
                    DatePopover.toggle()
                }) {
                    if breakDaysMode == 0 {
                        Text("\(formatDate(date: presetFirstDayOfSchool(), format: "MMM d YYYY"))")
                            .frame(width: 90, height: 30)
                    }
                    else {
                        Text("\(formatDate(date: firstDayOfSchool, format: "MMM d YYYY"))")
                            .frame(width: 90, height: 30)
                    }
                }
                .buttonStyle(ModernButtonStyle())
                .popover(isPresented: $DatePopover) {
                    VStack {
                        DatePicker(selection: $firstDayOfSchool, displayedComponents: .date) {}
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                    }
                    .frame(width: 156, height: 184)
                }
                .disabled(breakDaysMode == 0)
                #endif
            }
            .opacity(breakDaysMode == 0 ? 0.3 : 1)
        }
        .padding(32)
        #if os(macOS)
            .frame(width: 192)
        #endif
            .onChange(of: breakDaysMode) {
                if breakDaysMode == 0 {
                    firstDayOfSchool = Date().onlyDate!
                }
            }
        VStack {
            Text("* You can drag over the dates to select them; it makes the process a lot faster :)")
                .foregroundStyle(.secondary)
            #if os(iOS)
                .font(.system(size: 11.5))
                .padding(.bottom)
            #elseif os(macOS)
                .font(.callout)
            #endif
                .padding(.horizontal, 32)
                .frame(width: 300)
            
            let DisplayedMonth = Calendar.current.date(byAdding: .month, value: currentMonth, to: date)!
            let FirstDayOfMonth = Calendar.current.date(byAdding: .day, value: -Calendar.current.component(.day, from: DisplayedMonth) + 1, to: DisplayedMonth)!
            HStack {
                Text("\(formatDate(date: DisplayedMonth, format: "MMMM YYYY")) ").fontWeight(.bold)
                    .font(.system(size: 16))
                Spacer()
                HStack {
                    Button(action: {
                        withAnimation(.linear(duration: 0.1)) {currentMonth -= 1}
                    }) {
                        Image(systemName: "chevron.left").fontWeight(.bold)
                    }
                    Button {
                        withAnimation(.snappy(duration: 0.3, extraBounce: 0.32)) {
                            currentMonth = 0
                        }
                    } label: {
                        Image(systemName: "smallcircle.filled.circle")
                            .fontWeight(.bold)
                    }
                    .disabled(currentMonth == 0)
                    .clipShape(Circle())
                    .padding(.horizontal, 12)
                    Button(action: {
                        withAnimation(.linear(duration: 0.1)) {currentMonth += 1}
                    }) {
                        Image(systemName: "chevron.right").fontWeight(.bold)
                    }
                }
                #if os(macOS)
                    .buttonStyle(PlainButtonStyle())
                #endif
            }
            .frame(width: 220)
            
            HStack {
                ForEach(0 ..< 7) { day in
                    Text("\(daysOfWeek[day])")
                        .font(.system(size: 11))
                        .frame(width: 25, height: 25)
                        .bold()
                }
            }
            ZStack {
                if breakDaysMode == 0 {
                    Text("Automatically Selected").bold()
                }
                VStack() {
                    ForEach(0 ..< 6) { weeks in
                        HStack {
                            ForEach(0 ..< 7) { days in
                                let DisplayedDay = Calendar.current.date(byAdding: .day, value: weeks*7+days - Calendar.current.component(.weekday, from: FirstDayOfMonth) + 1, to: FirstDayOfMonth)!
                                GeometryReader { geometry in
                                    ZStack {
                                        if DisplayedDay == date {
                                            RoundedRectangle(cornerRadius: 9)
                                                .stroke(lineWidth: 1.5)
                                                .foregroundColor(chosenTint)
                                                .frame(width: 28, height: 28)
                                                .shadow(color: chosenTint, radius: 3)
                                        }
                                        if breakDaysMode == 0 {
                                            if loadedPresetBreakDays.contains(DisplayedDay.onlyDate!) || Calendar.current.isDateInWeekend(DisplayedDay.onlyDate!) {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .frame(width: 25, height: 25)
                                                    .foregroundStyle(chosenTint)
                                                    .opacity(0.8)
                                                    .shadow(color: chosenTint, radius: 3)
                                            }
                                        }
                                        else {
                                            if BreakDays.contains(DisplayedDay.onlyDate!) || Calendar.current.isDateInWeekend(DisplayedDay.onlyDate!) {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .frame(width: 25, height: 25)
                                                    .foregroundStyle(chosenTint)
                                                    .opacity(0.8)
                                                    .shadow(color: chosenTint, radius: 3)
                                            }
//                                            if CustomBreakDays.contains(where: $0.breakdate == DisplayedDay.onlydate!) || Calendar.current.isDateInWeekend(DisplayedDay.onlyDate!) {
//                                                RoundedRectangle(cornerRadius: 8)
//                                                    .frame(width: 25, height: 25)
//                                                    .foregroundStyle(chosenTint)
//                                                    .opacity(0.8)
//                                                    .shadow(color: chosenTint, radius: 3)
//                                            }
                                        }
                                        if Calendar.current.component(.month, from: DisplayedDay) == Calendar.current.component(.month, from: DisplayedMonth) {
                                            Text("\(Calendar.current.component(.day, from: DisplayedDay))")
                                                .foregroundColor((DisplayedDay == date && DisplayedDay != date) ? chosenTint : .primary)
                                                .font(.system(size: 12))
                                        }
                                        else {
                                            Text("\(Calendar.current.component(.day, from: DisplayedDay))")
                                                .opacity(0.3)
                                                .font(.system(size: 12))
                                        }
                                    }
                                    .frame(width: 25, height: 25)
                                    .contentShape(Rectangle())
                                    .preference(key: CardPreferenceKey.self,
                                                value: [CardPreferenceData(squareDate: DisplayedDay, bounds: geometry.frame(in: .named("GameSpace")))])
                                    
                                    
                                    
                                    
                                    .opacity(breakDaysMode == 0 ? 0.3 : 1)
                                    
                                    
                                    
                                    
                                }
                                .frame(width: 25, height: 25)
                            }
                        }
                    }
                }
            }
            
        }
        .padding()
        .frame(width: 264, height: 336)
        .background(ModernBackground(radius: 14))
        #if os(iOS)
        .scaleEffect(1.2)
        .padding(32)
        #elseif os(macOS)
        .padding()
        #endif
        .onPreferenceChange(CardPreferenceKey.self) { value in
            cardsData = value
        }
        .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        if breakDaysMode != 0 {
                            if let data = cardsData.first(where: {$0.bounds.contains(drag.location)}) {
                                if !Calendar.current.isDateInWeekend(data.squareDate) {
                                    if !dragBegins {
                                        if !BreakDays.contains(data.squareDate.onlyDate!) {
                                            withAnimation {
                                                BreakDays.append(data.squareDate.onlyDate!)
                                                BreakDays.sort()
                                            }
                                            
                                            
//                                            modelContext.insert(BreakDay(breakdate: data.squareDate.onlyDate!, breaktype: BreakDayType.holiday))
//                                            print(CustomBreakDays)
                                            appendQuestionMark = 1
                                        }
                                        else {
                                            withAnimation {
                                                BreakDays.removeAll(where: {$0 == data.squareDate.onlyDate!})
                                            }
                                            
//                                            modelContext.delete(BreakDay(breakdate: data.squareDate.onlyDate!, breaktype: BreakDayType.holiday))
                       
                                            
                                            appendQuestionMark = 0
                                        }
                                        dragBegins = true
                                    }
                                    else {
                                        if appendQuestionMark == 1 {
                                            if !BreakDays.contains(data.squareDate.onlyDate!) {
                                                withAnimation {
                                                    BreakDays.append(data.squareDate.onlyDate!)
                                                    BreakDays.sort()
                                                }
                                                
//                                                modelContext.insert(BreakDay(breakdate: data.squareDate.onlyDate!, breaktype: BreakDayType.holiday))
                                            }
                                        }
                                        else if appendQuestionMark == 0 {
                                            if BreakDays.contains(data.squareDate.onlyDate!) {
                                                withAnimation {
                                                    BreakDays.removeAll(where: {$0 == data.squareDate.onlyDate!})
                                                }
                                                
//                                                modelContext.delete(BreakDay(breakdate: data.squareDate.onlyDate!, breaktype: BreakDayType.holiday))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        if breakDaysMode != 0 {
                            dragBegins = false
                        }
                    }
                
                
        )
        .coordinateSpace(name: "GameSpace")
        .onChange(of: BreakDays) {
            #if os(iOS)
            let impactHeavy = UIImpactFeedbackGenerator(style: .light)
                impactHeavy.impactOccurred()
            #elseif os(macOS)
            NSHapticFeedbackManager.defaultPerformer.perform(NSHapticFeedbackManager.FeedbackPattern.levelChange, performanceTime: .now)
            #endif
        }
        
        VStack {
            if BreakDays.isEmpty {
                Spacer()
                Text("No break days added")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            else {
                ScrollView {
                    ForEach(BreakDays, id: \.self) { day in
                        Text("\(formatDate(date: day, format: "MMM dd YYYY"))")
                        if day != BreakDays.last {
                            Divider().frame(width: 80)
                        }
                    }
                    .padding(.horizontal, 8)
                }
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(chosenTint, lineWidth: 2)
                        .shadow(color: chosenTint, radius: 5)
                )
                .scrollContentBackground(.hidden)
                VStack {
                    Text("Selected Break Days:")
                    Button("Clear All") {
                        showAlert.toggle()
                    }
                    .disabled(BreakDays.isEmpty || breakDaysMode == 0)
                    .alert("Clear the entire list?", isPresented: $showAlert) {
                        HStack {
                            Button("Yes") {
                                withAnimation {
                                    BreakDays.removeAll()
                                }
                                
//                                do {
//                                    try modelContext.delete(model: BreakDay.self)
//                                } catch {
//                                    print("Failed to clear all custom break days.")
//                                }
////                                modelContext.delete(model: CustomBreakDays.self)
                            }
                            Button("No") {
                            }
                        }
                    }
                }
                
            }
        }
        .opacity(breakDaysMode == 0 ? 0.3 : 1)
    }
        
}

struct BreakDaysEditingView: View {
    @AppStorage("BreakDays") var BreakDays: [Date] = []
    @Environment(\.colorScheme) var colorMode
    
    var body: some View {
        VStack {
            #if os(iOS)
            ScrollView {
                BreakDaysSelectingView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollContentBackground(.hidden)
            .background(colorMode == .light ? Color(red: 242/255, green: 242/255, blue: 245/255) : .black)
            #elseif os(macOS)
            HStack(content: BreakDaysSelectingView.init)
                .frame(height: 348)
            #endif
        }
        .animation(.smooth(duration: 0.15), value: BreakDays)
        
        
/// =========================================================
    
    
    /// BELOW IS USED FOR GENERATING THE AUTOMATIC DATES!!!
        
//        .onChange(of: BreakDays) { change in
//            print(BreakDays)
//        }
        
        
/// =========================================================
    }
    
}

struct OnboardView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    @Environment(\.colorScheme) var colorMode
    
    @AppStorage("Blocks") var Blocks: [String] = ["", "", "", "", "", "", "", ""]
    @AppStorage("Onboard2.0") var Onboardy = true
    
    @Binding var onboardView: Bool

    @State var slide1 = true
    @State var slide2 = false
    @State var slide3 = false
    
    @State var showText = false
    @State var between1and2 = false
    @State var between2and3 = false
    
    var body: some View {
        VStack {
            if slide1 {
                VStack {
                    #if os(iOS)
                    Image("AppIconsForInAppUse")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .mask(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .shadow(radius: 16, y: 8)
                        .frame(width: 144, height: 144)
                    #elseif os(macOS)
                    Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 144, height: 144)
                    #endif
                    Text("Welcome to Scheduler 2.0!")
                        .font(.system(size: 48))
                        .fontWeight(.bold)
                        .fontDesign(.default)
                        .scaleEffect(showText ? 1 : 0.9)
                        .multilineTextAlignment(.center)
                        .opacity(showText ? 1 : 0.3)
                    Text("Updated for the 2024-2025 School Year")
                        .font(.system(size: 16))
                        .padding(.top)
                        .fontDesign(.rounded)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.push(from: between1and2 ? .trailing : .leading))
                .onAppear {
                    between1and2 = false
                    between2and3 = false
                    withAnimation(.smooth(duration: 0.6)) {
                        showText = true
                    }
                }
            }
            else if slide2 {
                VStack {
                    Text("CLASSES").fontWeight(.bold).font(.title)
                        .padding(.bottom)
                    HStack(spacing: 30) {
                        VStack(spacing: 18) {
                            Text("A Day Classes").fontWeight(.bold)
                            HStack {
                                Text("1A").fontWeight(.bold).foregroundStyle(.secondary)
                                TextField("1A Block", text: $Blocks[0])
                            }
                            HStack {
                                Text("2A").fontWeight(.bold).foregroundStyle(.secondary)
                                TextField("2A Block", text: $Blocks[1])
                            }
                            HStack {
                                Text("3A").fontWeight(.bold).foregroundStyle(.secondary)
                                TextField("3A Block", text: $Blocks[2])
                            }
                            HStack {
                                Text("4A").fontWeight(.bold).foregroundStyle(.secondary)
                                TextField("4A Block", text: $Blocks[3])
                            }
                        }
                        .frame(maxWidth: 264)
                        VStack(spacing: 18) {
                            Text("B Day Classes").fontWeight(.bold)
                            HStack {
                                Text("1B").fontWeight(.bold).foregroundStyle(.secondary)
                                TextField("1B Block", text: $Blocks[4])
                            }
                            HStack {
                                Text("2B").fontWeight(.bold).foregroundStyle(.secondary)
                                TextField("2B Block", text: $Blocks[5])
                            }
                            HStack {
                                Text("3B").fontWeight(.bold).foregroundStyle(.secondary)
                                TextField("3B Block", text: $Blocks[6])
                            }
                            HStack {
                                Text("4B").fontWeight(.bold).foregroundStyle(.secondary)
                                TextField("4B Block", text: $Blocks[7])
                            }
                        }
                        .frame(maxWidth: 264)
                    }
                }
                .padding(.horizontal, 32)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.push(from: between1and2 || between2and3 ? .trailing : .leading))
                .onAppear {
                    between1and2 = false
                    between2and3 = false
                }
            }
            else if slide3 {
                VStack {
                    BreakDaysEditingView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.push(from: between2and3 ? .trailing : .leading))
                .onAppear {
                    between2and3 = false
                }
            }
            Spacer()
            HStack {
                Button {
                    if slide1 {
                        showText = false
                        withAnimation(.smooth(duration: 0.2)) {
                            onboardView = false
                        }
                        #if os(macOS)
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
                        #endif
                    }
                    else if slide2 {
                        between1and2 = false
                        withAnimation(.smooth(duration: 0.2)) {
                            swap(&slide2, &slide1)
                        }
                    }
                    else if slide3 {
                        between2and3 = false
                        withAnimation(.smooth(duration: 0.2)) {
                            swap(&slide3, &slide2)
                        }
                    }
                } label: {
                    Text(slide1 ? "Skip" : "Back")
                        .frame(width: 78, height: 24)
                }
                #if os(iOS)
                .buttonStyle(BorderedProminentButtonStyle())
                #endif
                Spacer()
                Button {
                    if slide1 {
                        between1and2 = true
                        withAnimation(.smooth(duration: 0.2)) {
                            swap(&slide1, &slide2)
                        }
                    }
                    else if slide2 {
                        between2and3 = true
                        withAnimation(.smooth(duration: 0.2)) {
                            swap(&slide2, &slide3)
                        }
                    }
                    else if slide3 {
                        withAnimation(.smooth(duration: 0.2)) {
                            onboardView = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            swap(&slide3, &slide1)
                        }
                        #if os(macOS)
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
                        #endif
                    }
                } label: {
                    Text(slide3 ? "Done!" : "Continue")
                        .frame(width: 78, height: 24)
                }
                #if os(iOS)
                .buttonStyle(BorderedProminentButtonStyle())
                #endif
            }
            .padding(32)
            .padding(.horizontal)
            #if os(iOS)
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
            #endif
        }
        #if os(iOS)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .background(colorMode == .light ? Color(UIColor.systemGray6) : Color(hue: 0, saturation: 0, brightness: 15/255))
        #elseif os(macOS)
        .transition(.opacity)
        .textFieldStyle(ModernTextFieldStyle())
        .textFieldStyle(.plain)
        #endif
        .onAppear {
            if Onboardy {
                onboardView = true
                Onboardy = false
            }
            #if os(macOS)
            if let window = NSApplication.shared.windows.first {
                let initialSize = CGSize(width: 924, height: 660)
                var frame = window.frame
                frame.size = initialSize
                if let screen = window.screen {
                    let screenFrame = screen.visibleFrame
                    frame.origin.x = screenFrame.origin.x + (screenFrame.width - frame.width) / 2
                    frame.origin.y = screenFrame.origin.y + (screenFrame.height - frame.height) / 2
                }
                window.setFrame(frame, display: true, animate: true)
            }
            #endif
        }
        .onChange(of: Blocks) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

//struct Onboard_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardView(onboardView: true)
//    }
//}
        

