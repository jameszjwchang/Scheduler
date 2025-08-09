//
//  Home.swift
//  Scheduler
//
//  Created by James Chang on 3/28/24.
//

import Foundation
import SwiftUI
import UserNotifications
import SwiftUIIntrospect
import WidgetKit
//import UniformTypeIdentifiers

struct DashboardView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    @Environment(\.colorScheme) var colorMode
    
    @AppStorage("firstDayOfSchool") var firstDayOfSchool: Date = Calendar.current.startOfDay(for: Date())
    @AppStorage("BreakDays") var BreakDays: [Date] = []
    @AppStorage("Blocks") var Blocks: [String] = ["", "", "", "", "", "", "", ""]
    
    @State var currentTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @State var updatingDate = Date()
    
    #if os(iOS)
//    @AppStorage("IntroSetup") var IntroSetup = true
//    @State var Setup = false
    @State var currentWeek = 0
    
    @AppStorage("Onboardyyy") var Onboardy = true
    @State private var onboardView = false
    #endif
    
    @State var currentMonth = 0
    
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @State var SelectedDay = Calendar.current.startOfDay(for: Date())
    
    @State var MonthlyView = 0
    
    @State var scrollOffset = CGFloat.zero
    
    @AppStorage("AppMode") var AppMode = "student"
    
    @AppStorage("breakDaysMode") var breakDaysMode = 0
    @State private var loadedPresetBreakDays: [Date] = presetBreakDays()
    
//    #if os(macOS)
//    @State private var fileURL: URL?
    
//    @State private var showingExporter = false
//        @State private var document = TextDocument(text: "Hello, world!")
//    #endif
    
    var body: some View {
        #if os(iOS)
        ZStack {
            ObservableScrollView(scrollOffset: $scrollOffset) { proxy in
                VStack {
                    HStack {
                        Text(6...12 ~= Calendar.current.component(.hour, from: updatingDate) ? "Good Morning!" : (13...17 ~= Calendar.current.component(.hour, from: updatingDate) ? "Good Afternoon!" : "Good Evening!"))
                            .font(.system(size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(chosenTint)
                            .padding(.horizontal, 24)
                        Spacer()
                        Button("Setup") {
                            onboardView = true
                        }
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)
                        .fullScreenCover(isPresented: $onboardView) {
                            OnboardView(onboardView: $onboardView)
                        }
                        .onAppear {
                            onboardView = Onboardy
                            Onboardy = false
                        }
                        .padding(.trailing)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    Text("Today is \(updatingDate.formatted(date: .complete, time: .omitted))")
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    
                    Divider()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 8)
                    if AppMode == "teacher" {
                        NavigationLink {
                            TeacherTools()
                                .background(colorMode == .light ? Color(UIColor.systemGray6) : Color(hue: 0, saturation: 0, brightness: 15/255))
                        } label: {
                            Label("Teacher Utilities", systemImage: "bolt")
                                .padding(.horizontal, 32)
                                .padding(8)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .opacity(0.2)
                                }
                        }
                        Divider()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                    }
                    
                    VStack {
                        VStack {
                            HStack {
                                Picker("", selection: $MonthlyView.animation(.smooth)) {
                                    Text("Weekly")
                                        .clipShape(Capsule())
                                        .tag(0)
                                    Text("Monthly")
                                        .clipShape(Capsule())
                                        .tag(1)
                                }
                                .labelsHidden()
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.bottom, 4)
                            }
                            
                            let DisplayedWeek = Calendar.current.date(byAdding: .day, value: currentWeek * 7, to: SelectedDay)!
                            let FirstDayOfWeek = Calendar.current.date(byAdding: .day, value: 1-Calendar.current.component(.weekday, from: DisplayedWeek), to: DisplayedWeek)!
                            
                            let DisplayedMonth = Calendar.current.date(byAdding: .month, value: currentMonth, to: SelectedDay)!
                            let FirstDayOfMonth = Calendar.current.date(byAdding: .day, value: 1 - Calendar.current.component(.day, from: DisplayedMonth), to: DisplayedMonth)!
                            
                            /// # IF SELECTED VIEW IS WEEKLY
                            
                            if MonthlyView == 0 {
                                HStack {
                                    (
                                        Text("\(formatDate(date: FirstDayOfWeek, format: "MMM dd"))")
                                        + Text("   ")
                                        + Text(Image(systemName: "arrow.right"))
                                        + Text("   ")
                                        + Text("\(formatDate(date: Calendar.current.date(byAdding: .day, value: 6, to: FirstDayOfWeek)!, format: "MMM dd"))")
                                        + Text(" ").font(.system(size: 20))
                                    )
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    Spacer()
                                    
                                    HStack {
                                        Button(action: {
                                            withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {currentWeek -= 1}
                                        }) {Image(systemName: "chevron.left").fontWeight(.bold)}
                                        Button {
                                            withAnimation(.snappy(duration: 0.3, extraBounce: 0.32)) {
                                                currentWeek = 0
                                                SelectedDay = Date().onlyDate!
                                                
                                                currentMonth = 0
                                            }
                                        } label: {
                                            Image(systemName: "smallcircle.filled.circle")
                                                .fontWeight(.bold)
                                        }
                                        .disabled(SelectedDay == Date().onlyDate! && currentWeek == 0)
                                        .padding(.horizontal, 12)
                                        
                                        Button(action: {
                                            withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {currentWeek += 1}
                                        }) {Image(systemName: "chevron.right").fontWeight(.bold)}
                                    }
                                }
                                .padding(.horizontal, 4)
                                
                                HStack {
                                    ForEach(0 ..< 7) { days in
                                        Text("\(daysOfWeek[days])")
                                            .font(.system(size: 14))
                                            .bold()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                HStack {
                                    ForEach(0 ..< 7) { days in
                                        // DisplayedDay is the day in each instance of the forloop.
                                        let DisplayedDay = Calendar.current.date(byAdding: .day, value: days, to: FirstDayOfWeek)!
                                        ZStack {
                                            if DisplayedDay == Calendar.current.startOfDay(for: updatingDate) {
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(lineWidth: 1.5)
                                                    .foregroundColor(chosenTint)
                                                    .frame(width: 31, height: 31)
                                                    .shadow(color: chosenTint, radius: 5)
                                            }
                                            
                                            Rectangle()
                                                .frame(width: DisplayedDay == SelectedDay ? 32 : 28, height: DisplayedDay == SelectedDay ? 32 : 28)
                                                .cornerRadius(10)
                                                .foregroundStyle(DisplayedDay == SelectedDay ? chosenTint : .clear)
                                                .shadow(color: chosenTint, radius: 3)
                                            
                                            Text("\(Calendar.current.component(.day, from: DisplayedDay))")
                                                .foregroundStyle((DisplayedDay == Calendar.current.startOfDay(for: updatingDate) && DisplayedDay != SelectedDay) ? chosenTint : .primary)
                                                .font(.system(size: 15))
                                        }
                                        .onTapGesture {
                                            withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {
                                                SelectedDay = DisplayedDay
                                                currentWeek = 0
                                            }
                                        }
                                        .frame(width: 32, height: 32)
                                    }
                                }
                                .onAppear {
                                    SelectedDay = Date().onlyDate!
                                    currentWeek = 0
                                    currentMonth = 0
                                }
                            }
                            
                            /// # IF SELECTED VIEW IS MONTHLY
                            
                            else {
                                HStack {
                                    Text("\(formatDate(date: DisplayedMonth, format: "MMMM YYYY")) ")
                                        .font(.system(size: 20))
                                        .fontWeight(.bold)
                                    Spacer()
                                    HStack {
                                        Button(action: {
                                            withAnimation(.linear(duration: 0.1)) {currentMonth -= 1}
                                        }) {Image(systemName: "chevron.left").fontWeight(.bold)}
                                        
                                        Button(action: {
                                            withAnimation(.snappy(duration: 0.3, extraBounce: 0.32)) {
                                                currentMonth = 0
                                                SelectedDay = Date().onlyDate!
                                                
                                                currentWeek = 0
                                            }
                                        }) {
                                            Image(systemName: "smallcircle.filled.circle")
                                                .fontWeight(.bold)
                                        }
                                        .disabled(SelectedDay == Date().onlyDate! && currentMonth == 0)
                                        .padding(.horizontal, 12)
                                        
                                        Button(action: {
                                            withAnimation(.linear(duration: 0.1)) {currentMonth += 1}
                                        }) {Image(systemName: "chevron.right").fontWeight(.bold)}
                                    }
                                }
                                .padding(.horizontal, 4)
                                
                                HStack {
                                    ForEach(0 ..< 7) { day in
                                        Text("\(daysOfWeek[day])")
                                            .font(.system(size: 14))
                                            .bold()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                VStack {
                                    ForEach(0 ..< 6) { weeks in
                                        HStack {
                                            ForEach(0 ..< 7) { days in
                                                let DisplayedDay = Calendar.current.date(byAdding: .day, value: weeks*7+days - Calendar.current.component(.weekday, from: FirstDayOfMonth) + 1, to: FirstDayOfMonth)!
                                                ZStack {
                                                    if DisplayedDay == Calendar.current.startOfDay(for: updatingDate) {
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .stroke(lineWidth: 1.5)
                                                            .foregroundColor(chosenTint)
                                                            .frame(width: 31, height: 31)
                                                            .shadow(color: chosenTint, radius: 5)
                                                    }
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .frame(width: DisplayedDay == SelectedDay ? 32 : 28, height: DisplayedDay == SelectedDay ? 32 : 28)
                                                        .foregroundStyle(DisplayedDay == SelectedDay ? chosenTint : .clear)
                                                        .shadow(color: chosenTint, radius: 3)
                                                    if Calendar.current.component(.month, from: DisplayedDay) == Calendar.current.component(.month, from: DisplayedMonth) {
                                                        Text("\(Calendar.current.component(.day, from: DisplayedDay))")
                                                            .foregroundColor((DisplayedDay == Calendar.current.startOfDay(for: updatingDate) && DisplayedDay != SelectedDay) ? chosenTint : .primary)
                                                            .font(.system(size: 15))
                                                    }
                                                    else {
                                                        Text("\(Calendar.current.component(.day, from: DisplayedDay))")
                                                            .opacity(0.3)
                                                            .font(.system(size: 15))
                                                    }
                                                }
                                                .onTapGesture {
                                                    withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {
                                                        SelectedDay = DisplayedDay
                                                        currentMonth = 0
                                                    }
                                                }
                                                .frame(width: 32, height: 32)
                                            }
                                        }
                                    }
                                    .onAppear {
                                        SelectedDay = Date().onlyDate!
                                        currentMonth = 0
                                        currentWeek = 0
                                    }
                                }
                            }
                        }
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: MonthlyView == 1 ? 20 : 16, trailing: 16))
                        .background(ModernBackground(radius: 14))
                        
                        VStack {
                            HStack {
                                Button(action: {
                                    withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {
                                        MonthlyView == 0 ? (currentWeek = 0) : (currentMonth = 0)
                                        SelectedDay = Calendar.current.date(byAdding: .day, value: -1, to: SelectedDay)!
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 24))
                                        .padding(6)
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .clipShape(Circle())
                                
                                Text("\(formatDate(date: SelectedDay, format: "MMM d, YYYY"))")
                                    .fontWeight(.bold)
                                    .font(.system(size: 22))
                                    .padding(.horizontal)
                                
                                Button(action: {
                                    withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {
                                        MonthlyView == 0 ? (currentWeek = 0) : (currentMonth = 0)
                                        
                                        SelectedDay = Calendar.current.date(byAdding: .day, value: 1, to: SelectedDay)!
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 24))
                                        .padding(6)
                                }
                                .buttonStyle(BorderedButtonStyle())
                                .clipShape(Circle())
                            }
                            .padding(.top)
                            
                            VStack {
                                if rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay) != -1 {
                                    (Text(rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay) % 2 == 1 ? "A" : "B") + Text(" day (Rotation \(rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay)))")).bold().padding(.bottom, 8)
                                }
                                switch rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay) {
                                case 1:
                                    Text("1A: \(Blocks[0])")
                                    Spacer()
                                    Text("2A: \(Blocks[1])")
                                    Spacer()
                                    Text("3A: \(Blocks[2])")
                                    Spacer()
                                    Text("4A: \(Blocks[3])")
                                case 2:
                                    Text("1B: \(Blocks[4])")
                                    Spacer()
                                    Text("2B: \(Blocks[5])")
                                    Spacer()
                                    Text("3B: \(Blocks[6])")
                                    Spacer()
                                    Text("4B: \(Blocks[7])")
                                case 3:
                                    Text("2A: \(Blocks[1])")
                                    Spacer()
                                    Text("3A: \(Blocks[2])")
                                    Spacer()
                                    Text("4A: \(Blocks[3])")
                                    Spacer()
                                    Text("1A: \(Blocks[0])")
                                case 4:
                                    Text("2B: \(Blocks[5])")
                                    Spacer()
                                    Text("3B: \(Blocks[6])")
                                    Spacer()
                                    Text("4B: \(Blocks[7])")
                                    Spacer()
                                    Text("1B: \(Blocks[4])")
                                case 5:
                                    Text("3A: \(Blocks[2])")
                                    Spacer()
                                    Text("4A: \(Blocks[3])")
                                    Spacer()
                                    Text("1A: \(Blocks[0])")
                                    Spacer()
                                    Text("2A: \(Blocks[1])")
                                case 6:
                                    Text("3B: \(Blocks[6])")
                                    Spacer()
                                    Text("4B: \(Blocks[7])")
                                    Spacer()
                                    Text("1B: \(Blocks[4])")
                                    Spacer()
                                    Text("2B: \(Blocks[5])")
                                case 7:
                                    Text("4A: \(Blocks[3])")
                                    Spacer()
                                    Text("1A: \(Blocks[0])")
                                    Spacer()
                                    Text("2A: \(Blocks[1])")
                                    Spacer()
                                    Text("3A: \(Blocks[2])")
                                case 8:
                                    Text("4B: \(Blocks[7])")
                                    Spacer()
                                    Text("1B: \(Blocks[4])")
                                    Spacer()
                                    Text("2B: \(Blocks[5])")
                                    Spacer()
                                    Text("3B: \(Blocks[6])")
                                default:
                                    Text("No school on this day!")
                                        .bold()
                                }
                            }
                            .padding(.bottom)
                            .frame(minHeight: 264)
                        }
                        .animation(.easeInOut(duration: 0.1), value: SelectedDay)
                    }
                    .padding(EdgeInsets(top: 16, leading: 48, bottom: 48, trailing: 48))
                    .background {
                        ModernBackground(radius: 22)
                            .padding(EdgeInsets(top: 0, leading: 32, bottom: 32, trailing: 32))
                    }
                    Group {
                        Text("Copyright © 2022-2024 James Chang\n\n")
                    }
                    .font(.system(size: 10))
                    .foregroundColor(chosenTint)
                }
            }
            .background(colorMode == .light ? Color(UIColor.systemGray6) : Color(hue: 0, saturation: 0, brightness: 15/255))
//            .sheet(isPresented: $IntroSetup) {
//                SetupView()
//            }
//            .sheet(isPresented: $Setup) {
//                SetupView()
//            }
            .onReceive(currentTimer) { _ in
                if Calendar.current.startOfDay(for: updatingDate) != Calendar.current.startOfDay(for: Date()) {
                    SelectedDay = Calendar.current.startOfDay(for: updatingDate)
                }
                updatingDate = Date()
            }
#if os(iOS)
            .onChange(of: SelectedDay) {
                let impactHeavy = UIImpactFeedbackGenerator(style: .soft)
                impactHeavy.impactOccurred()
            }
#endif
            VStack(spacing: 0) {
                Rectangle()
                    .foregroundStyle(Material.regular)
                    .opacity(scrollOffset > 10 ? 1 : (scrollOffset >= 0 ? scrollOffset / 10 : 0))
                    .frame(height: 54)
                Rectangle()
                    .foregroundStyle(colorMode == .light ? Color(UIColor.lightGray) : Color(UIColor.darkGray))
                    .frame(height: 1)
                    .opacity(scrollOffset > 10 ? 1 : (scrollOffset >= 0 ? scrollOffset / 10 : 0))
                    .opacity(0.5)
                Spacer()
            }
            .ignoresSafeArea(.all)
            
            if AppMode == "student" {
                VStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .foregroundStyle(colorMode == .light ? Color(UIColor.lightGray) : Color(UIColor.darkGray))
                        .frame(height: 1)
                        .opacity(scrollOffset <= 30 ? 1 : scrollOffset < 40 ? (40-scrollOffset) * 0.1 : 0)
                        .opacity(0.5)
                    Rectangle()
                        .foregroundStyle(Material.regular)
                        .opacity(scrollOffset <= 30 ? 1 : scrollOffset < 40 ? (40-scrollOffset) * 0.1 : 0)
                        .frame(height: 89)
                }
                .ignoresSafeArea(.all)
            }
            else if AppMode == "teacher" {
                VStack(spacing: 0) {
                    Spacer()
                    Rectangle()
                        .foregroundStyle(colorMode == .light ? Color(UIColor.lightGray) : Color(UIColor.darkGray))
                        .frame(height: 1)
                        .opacity(scrollOffset <= 100 ? 1 : scrollOffset < 110 ? (110-scrollOffset) * 0.1 : 0)
                        .opacity(0.5)
                    Rectangle()
                        .foregroundStyle(Material.regular)
                        .opacity(scrollOffset <= 100 ? 1 : scrollOffset < 110 ? (110-scrollOffset) * 0.1 : 0)
                        .frame(height: 89)
                }
                .ignoresSafeArea(.all)
            }
        }
        #elseif os(macOS)
        VStack {
//            Button("Create File") {
//                createFile()
//            }
//            
//            if let fileURL = fileURL {
//                Text("File created at: \(fileURL.path)")
//            }
//            
//            Button("Export") {
//                        showingExporter = true
//                    }
//                    .fileExporter(isPresented: $showingExporter, document: document, contentType: .plainText) { result in
//                        switch result {
//                        case .success(let url):
//                            print("Exported to \(url)")
//                        case .failure(let error):
//                            print("Error exporting file: \(error.localizedDescription)")
//                        }
//                    }
            VStack {
                Text("Good " + (6...12 ~= Calendar.current.component(.hour, from: updatingDate) ? "Morning!" : (13...17 ~= Calendar.current.component(.hour, from: updatingDate) ? "Afternoon!" : "Evening!")))
                    .font(.system(size: 28))
                    .bold()
                    .foregroundColor(chosenTint)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                Text("Today is \(updatingDate.formatted(date: .complete, time: .omitted))")
                    .font(.system(size: 14))
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                VStack {
                    Divider()
                        .frame(width: 228, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .frame(width: 512)
            
            HStack {
                VStack {
                    let DisplayedMonth = Calendar.current.date(byAdding: .month, value: currentMonth, to: SelectedDay)!
                    let FirstDayOfMonth = Calendar.current.date(byAdding: .day, value: -Calendar.current.component(.day, from: DisplayedMonth) + 1, to: DisplayedMonth)!
                    
                    HStack {
                        ZStack {
                            Button("") {
                                withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {
                                    currentMonth = 0
                                    SelectedDay = Calendar.current.date(byAdding: .day, value: -1, to: SelectedDay)!
                                }
                            }
                            .opacity(0)
                            .keyboardShortcut(.leftArrow, modifiers: [])
                            Button {
                                withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {
                                    currentMonth = 0
                                    SelectedDay = Calendar.current.date(byAdding: .day, value: -1, to: SelectedDay)!
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .contentShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, 4)
                        }
                        
                        Divider()
                        Button("Today") {
                            withAnimation(.snappy(duration: 0.3, extraBounce: 0.32)) {
                                currentMonth = 0
                                SelectedDay = Date().onlyDate!
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(SelectedDay == Date().onlyDate! && currentMonth == 0)
                        .animation(nil, value: true)
                        Divider()
                        
                        ZStack {
                            Button("") {
                                withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {
                                    currentMonth = 0
                                    SelectedDay = Calendar.current.date(byAdding: .day, value: 1, to: SelectedDay)!
                                }
                            }
                            .opacity(0)
                            .keyboardShortcut(.rightArrow, modifiers: [])
                            
                            Button {
                                withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {
                                    currentMonth = 0
                                    SelectedDay = Calendar.current.date(byAdding: .day, value: 1, to: SelectedDay)!
                                }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .contentShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 4)
                        }
                    }
                    .fontWeight(.bold)
                    .padding(8)
                    .glass(cornerRadius: (12.0, 12.0), shadowRadius: (3, 3))
                    .frame(height: 28)
                    .padding(.bottom, 8)
                    
                    HStack {
                        Text("\(formatDate(date: DisplayedMonth, format: "MMMM YYYY")) ")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                withAnimation(.linear(duration: 0.1)) {currentMonth -= 1}
                            }) {Image(systemName: "chevron.left").fontWeight(.bold)}
                                .buttonStyle(PlainButtonStyle())
                            
                            Button {
                                withAnimation(.snappy(duration: 0.3, extraBounce: 0.32)) {
                                    currentMonth = 0
                                    SelectedDay = Date().onlyDate!
                                }
                            } label: {
                                Image(systemName: "smallcircle.filled.circle")
                                    .fontWeight(.bold)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(SelectedDay == Date().onlyDate! && currentMonth == 0)
                            .clipShape(Circle())
                            
                            Button(action: {
                                withAnimation(.linear(duration: 0.1)) {currentMonth += 1}
                            }) {Image(systemName: "chevron.right").fontWeight(.bold)}
                                .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(width: 220)
                    
                    HStack {
                        ForEach(0 ..< 7) { day in
                            Text("\(daysOfWeek[day])")
                                .font(.system(size: 11))
                                .bold()
                                .frame(width: 25, height: 25)
                        }
                    }
                    
                    ForEach(0 ..< 6) { weeks in
                        HStack {
                            ForEach(0 ..< 7) { days in
                                let DisplayedDay = Calendar.current.date(byAdding: .day, value: weeks*7+days - Calendar.current.component(.weekday, from: FirstDayOfMonth) + 1, to: FirstDayOfMonth)!
                                ZStack {
                                    if DisplayedDay == Calendar.current.startOfDay(for: Date()) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(lineWidth: 1.5)
                                            .foregroundColor(chosenTint)
                                            .frame(width: 24, height: 24)
                                            .shadow(color: chosenTint, radius: 5)
                                    }
                                    RoundedRectangle(cornerRadius: 8)
                                        .frame(width: DisplayedDay == SelectedDay ? 25 : 23, height: DisplayedDay == SelectedDay ? 25 : 23)
                                        .foregroundStyle(DisplayedDay == SelectedDay ? chosenTint : .clear)
                                        .shadow(color: chosenTint, radius: 3)
                                    if Calendar.current.component(.month, from: DisplayedDay) == Calendar.current.component(.month, from: DisplayedMonth) {
                                        Text("\(Calendar.current.component(.day, from: DisplayedDay))")
                                            .foregroundColor((DisplayedDay == Calendar.current.startOfDay(for: Date()) && DisplayedDay != SelectedDay) ? chosenTint : .primary)
                                            .font(.system(size: 12))
                                    }
                                    else {
                                        
                                        Text("\(Calendar.current.component(.day, from: DisplayedDay))")
                                            .foregroundStyle(.tertiary)
                                            .font(.system(size: 12))
                                    }
                                }
                                .frame(width: 25, height: 25)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {
                                        currentMonth = 0
                                        SelectedDay = DisplayedDay
//                                            NSHapticFeedbackManager.defaultPerformer.perform(NSHapticFeedbackManager.FeedbackPattern.generic, performanceTime: .now)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                .glass(cornerRadius: (20.0, 20.0))
//                .background(ModernBackground(radius: 20))
                VStack {
                    Text("\(formatDate(date: SelectedDay, format: "MMM d, YYYY"))")
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                        .padding(.horizontal)
                        .padding(.bottom, 4)
                    if rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay) != -1 {
                        (Text(rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay) % 2 == 1 ? "A" : "B") + Text(" day (Rotation \(rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay)))")).bold().padding(.bottom, 8)
                    }
                    VStack {
                        switch rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay) {
                        case 1:
                            Text("**1A**: \(Blocks[0])")
                            Spacer()
                            Text("**2A**: \(Blocks[1])")
                            Spacer()
                            Text("**3A**: \(Blocks[2])")
                            Spacer()
                            Text("**4A**: \(Blocks[3])")
                        case 2:
                            Text("**1B**: \(Blocks[4])")
                            Spacer()
                            Text("**2B**: \(Blocks[5])")
                            Spacer()
                            Text("**3B**: \(Blocks[6])")
                            Spacer()
                            Text("**4B**: \(Blocks[7])")
                        case 3:
                            Text("**2A**: \(Blocks[1])")
                            Spacer()
                            Text("**3A**: \(Blocks[2])")
                            Spacer()
                            Text("**4A**: \(Blocks[3])")
                            Spacer()
                            Text("**1A**: \(Blocks[0])")
                        case 4:
                            Text("**2B**: \(Blocks[5])")
                            Spacer()
                            Text("**3B**: \(Blocks[6])")
                            Spacer()
                            Text("**4B**: \(Blocks[7])")
                            Spacer()
                            Text("**1B**: \(Blocks[4])")
                        case 5:
                            Text("**3A**: \(Blocks[2])")
                            Spacer()
                            Text("**4A**: \(Blocks[3])")
                            Spacer()
                            Text("**1A**: \(Blocks[0])")
                            Spacer()
                            Text("**2A**: \(Blocks[1])")
                        case 6:
                            Text("**3B**: \(Blocks[6])")
                            Spacer()
                            Text("**4B**: \(Blocks[7])")
                            Spacer()
                            Text("**1B**: \(Blocks[4])")
                            Spacer()
                            Text("**2B**: \(Blocks[5])")
                        case 7:
                            Text("**4A**: \(Blocks[3])")
                            Spacer()
                            Text("**1A**: \(Blocks[0])")
                            Spacer()
                            Text("**2A**: \(Blocks[1])")
                            Spacer()
                            Text("**3A**: \(Blocks[2])")
                        case 8:
                            Text("**4B**: \(Blocks[7])")
                            Spacer()
                            Text("**1B**: \(Blocks[4])")
                            Spacer()
                            Text("**2B**: \(Blocks[5])")
                            Spacer()
                            Text("**3B**: \(Blocks[6])")
                        default:
                            Text("No school on this day!")
                                .bold()
                        }
                    }
                    .frame(width: 175, height: rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay) == -1 ? 30 : 250)
                }
            }
            .padding(20)
            .glass(cornerRadius: (20.0, 20.0))
            .padding(.bottom)
            Text("Copyright © 2022-2024 James Chang")
                .font(.system(size: 10))
                .foregroundColor(chosenTint)
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Schedule")
//        .refreshable {
//            reloadTrigger.toggle()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
//                reloadTrigger. toggle()
//            }
//        ｝
        .onReceive(currentTimer) { _ in
            if Calendar.current.startOfDay(for: updatingDate) != Calendar.current.startOfDay(for: Date()) {
                SelectedDay = Calendar.current.startOfDay(for: updatingDate)
            }
            updatingDate = Date()
            
            WidgetCenter.shared.reloadAllTimelines()
        }
        .onAppear {
            SelectedDay = Calendar.current.startOfDay(for: Date())
        }
        #endif
    }
//    #if os(macOS)
//    func createFile() {
//            do {
//                let fileURL = try FileManager.default.url(
//                    for: .documentDirectory,
//                    in: .userDomainMask,
//                    appropriateFor: nil,
//                    create: true
//                ).appendingPathComponent("new_file.txt")
//                
//                try "Hello, World testing!".write(to: fileURL, atomically: true, encoding: .utf8)
//                self.fileURL = fileURL
//            } catch {
//                print("Error creating file: \(error)")
//            }
//        }
//    #endif
    func rotationOfDate(startDate: Date, endDate: Date) -> Int {
        if breakDaysMode == 0 {
            var rotation = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: presetFirstDayOfSchool()), to: Calendar.current.startOfDay(for: endDate)).day!
            let dateRange = Date.dates(from: presetFirstDayOfSchool(), to: endDate)
            if Calendar.current.startOfDay(for: presetFirstDayOfSchool()) > Calendar.current.startOfDay(for: endDate) || loadedPresetBreakDays.contains(Calendar.current.startOfDay(for: endDate)) || Calendar.current.isDateInWeekend(endDate) {
                return -1
            }
            for day in dateRange {
                if Calendar.current.isDateInWeekend(day) || loadedPresetBreakDays.contains(Calendar.current.startOfDay(for: day)) {
                    rotation -= 1
                }
            }
            
            return rotation % 8 + 1
        }
        else {
            var rotation = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: startDate), to: Calendar.current.startOfDay(for: endDate)).day!
            let dateRange = Date.dates(from: startDate, to: endDate)
            if Calendar.current.startOfDay(for: startDate) > Calendar.current.startOfDay(for: endDate) || BreakDays.contains(Calendar.current.startOfDay(for: endDate)) || Calendar.current.isDateInWeekend(endDate) {
                return -1
            }
            for day in dateRange {
                if Calendar.current.isDateInWeekend(day) || BreakDays.contains(Calendar.current.startOfDay(for: day)) {
                    rotation -= 1
                }
            }
            
            return rotation % 8 + 1
        }
    }
    
}

//struct TextDocument: FileDocument {
//    static var readableContentTypes = [UTType.plainText]
//    var text: String = ""
//
//    init(text: String) {
//        self.text = text
//    }
//
//    init(configuration: FileDocumentReadConfiguration) throws {
//        if let data = configuration.file.regularFileContents {
//            text = String(decoding: data, as: UTF8.self)
//        } else {
//            text = ""
//        }
//    }
//
//    func fileWrapper(configuration: FileDocumentWriteConfiguration) throws -> FileWrapper {
//        return FileWrapper(regularFileWithContents: Data(text.utf8))
//    }
//}

struct Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


