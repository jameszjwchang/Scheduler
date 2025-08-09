//
//  TeacherTools.swift
//  Scheduler
//
//  Created by James Chang on 12/17/23.
//

import Foundation
import SwiftUI
import SwiftUIIntrospect

struct TeacherTools: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    
    @AppStorage("Events") var Events: [Event] = []
    @AppStorage("BreakDays") var BreakDays: [Date] = []
    @AppStorage("Blocks") var Blocks: [String] = ["", "", "", "", "", "", "", ""]
    
    @State var BlockTimes: [Int] = [0, 1, 1055, 2, 3]
    @AppStorage("BlockNotes") var BlockNotes: [BlockNote] = []
    
    @State private var selectedBlock: Int = 0
    @State private var startingDate: Date = Date()
    @State private var endingDate: Date = Date()
    @AppStorage("firstDayOfSchool") var firstDayOfSchool: Date = Date().onlyDate!
    
    @AppStorage("breakDaysMode") var breakDaysMode = 0
    @State private var loadedPresetBreakDays: [Date] = presetBreakDays()
    
    @State var currentWeek = 0
    let workDays = ["Sunday", "Monday", "Tueday", "Wednesday", "Thursday", "Friday", "Saturday"]
    @Environment(\.colorScheme) var colorMode
    
    var body: some View {
        TabView {
            VStack {
                let DisplayedWeek = Calendar.current.date(byAdding: .day, value: currentWeek * 7, to: Date())!
                let FirstDayOfWeek = Calendar.current.date(byAdding: .day, value: 2-Calendar.current.component(.weekday, from: DisplayedWeek), to: DisplayedWeek)!
                HStack {
                    (
                        Text("\(formatDate(date: FirstDayOfWeek, format: "MMM dd"))")
                        + Text("   ")
                        + Text(Image(systemName: "arrow.right"))
                        + Text("   ")
                        + Text("\(formatDate(date: Calendar.current.date(byAdding: .day, value: 4, to: FirstDayOfWeek)!, format: "MMM dd"))")
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
                            }
                        } label: {
                            Image(systemName: "smallcircle.filled.circle")
                                .fontWeight(.bold)
                        }
                        .disabled(currentWeek == 0)
                        .padding(.horizontal, 12)
                        
                        Button(action: {
                            withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {currentWeek += 1}
                        }) {Image(systemName: "chevron.right").fontWeight(.bold)}
                    }
                }
                .padding(.horizontal, 4)
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        ForEach(-1 ..< 6) { day in
                            let DisplayedDay = Calendar.current.date(byAdding: .day, value: day, to: FirstDayOfWeek)!
                            
                            VStack(spacing: 0) {
                                VStack {
                                    Text("\(workDays[day+1])")
                                        .font(.system(size: 14))
                                        .fontWeight(.bold)
                                        .lineLimit(1)
                                        .foregroundStyle((Calendar.current.startOfDay(for: DisplayedDay) == Calendar.current.startOfDay(for: Date())) ? chosenTint : .primary)
                                    Text("\(Calendar.current.component(.day, from: DisplayedDay))")
                                        .fontWeight(.bold)
                                        .foregroundStyle((Calendar.current.startOfDay(for: DisplayedDay) == Calendar.current.startOfDay(for: Date())) ? chosenTint : .primary)
                                }
                                .padding(2)
                                .frame(maxWidth: .infinity)
                                .border(.gray)
                                VStack(spacing: 0) {
                                    if rotationOfDate(startDate: firstDayOfSchool, endDate: DisplayedDay) != -1 {
                                        ForEach(BlockTimes, id: \.self) { block in
                                            VStack(spacing: 0) {
                                                Text(block == 1055 ? "EL" : "\(blocksOfGivenRotation(block: blocksNameOfGivenDate(date: DisplayedDay)[block])): \(Blocks[blocksNameOfGivenDate(date: DisplayedDay)[block]])")
                                                    .lineLimit(1)
                                                    .font(.system(size: 12))
                                                    .padding(4)
                                                Rectangle().frame(height: 1).opacity(0.3)
                                                if let index = BlockNotes.firstIndex(where: { Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: DisplayedDay) && $0.blockOfDay == block}) {
                                                    ZStack(alignment: .topTrailing) {
                                                        TextEditor(text: .constant(BlockNotes[index].note.isEmpty ? "Write a note here" : ""))
                                                            .scrollIndicators(.never)
                                                            .padding(.vertical, 2)
                                                            .padding(2)
                                                            .opacity(0.3)
                                                        TextEditor(text: $BlockNotes[index].note)
                                                            .scrollIndicators(.never)
                                                            .padding(.vertical, 4)
                                                            .padding(.horizontal, 1)
                                                            
                                                            
                                                        Button {
                                                            BlockNotes.remove(at: index)
                                                        } label: {
                                                            Image(systemName: "xmark")
                                                                .padding(5)
                                                        }
                                                        .buttonStyle(ModernButtonStyle(showOpaqueBackground: false, showTranslucentBackground: true, showHover: true))
                                                        .padding(4)
                                                    }
                                                }
                                                else {
                                                        Button {
                                                            BlockNotes.append(BlockNote(id: UUID().uuidString, note: "", date: DisplayedDay, blockOfDay: block))
                                                        } label: {
                                                            Image(systemName: "plus.rectangle")
                                                                .font(.system(size: 30))
                                                                .fontWeight(.light)
                                                                .opacity(0)
                                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                        }
                                                }
                                            }
                                            .border(.gray, width: 1)
                                        }
                                    }
                                    else {
                                        if 0 ..< 5 ~= day {
                                            Text("No School (Break)")
                                                .bold()
                                        }
                                        else {
                                            Text("WEEKEND")
                                                .bold()
                                                .rotationEffect(Angle.degrees(90))
                                                .lineLimit(1)
                                                .frame(width: 100)
                                        }
                                    }
                                }
                                .buttonStyle(MaterialButtonStyle(radius: 0, text: "Add Note"))
                                .frame(maxHeight: .infinity)
                            }
                            
                            
                            
                            
                            .frame(width: 0 ..< 5 ~= day ? geometry.size.width / 6 : geometry.size.width / 12, height: geometry.size.height)
                            
                            
                            
                            
                            .border(.gray) // this is the columns border
                        }
                    }
                }
                .border(.gray, width: 2) // this is the horizontal border. The boldness may require changing later.
            }
            #if os(iOS)
            .background(colorMode == .light ? Color(UIColor.systemGray6) : Color(hue: 0, saturation: 0, brightness: 15/255))
            #endif
            .tabItem {
                Text("Day Planner")
            }
            VStack {
                Text("This tool allows teachers to easily determine the number of classes within a specific date range, enabling better class planning and scheduling.")
                    .padding(.horizontal, 48)
                    .padding(.vertical)
                    .fontWeight(.bold)
                Picker("Block:", selection: $selectedBlock) {
                    ForEach(Blocks.indices) { i in
                        Text(Blocks[i]).tag(i)
                    }
                }
                .padding(48)
                HStack(spacing: 24) {
                    VStack {
                        Text("Start Date")
                            .fontWeight(.bold)
                        DatePicker("", selection: $startingDate, displayedComponents: .date)
                            .labelsHidden()
                        #if os(macOS)
                            .datePickerStyle(.graphical)
                        #endif
                    }
                    VStack {
                        Text("End Date")
                            .fontWeight(.bold)
                        DatePicker("", selection: $endingDate, displayedComponents: .date)
                            .labelsHidden()
#if os(macOS)
                            .datePickerStyle(.graphical)
#endif
                    }
                }
                if startingDate > endingDate || schoolDaysWithinDateRange(block: selectedBlock, startDate: startingDate, endDate: endingDate) == -1 {
                    Text("Invalid Date Range!")
                        .foregroundStyle(.red)
                        .fontWeight(.bold)
                }
                else {
                    Text("^[\(schoolDaysWithinDateRange(block: selectedBlock, startDate: startingDate, endDate: endingDate)) class](inflect: true) exist for \(Blocks[selectedBlock]) between \(startingDate.formatted(date: .complete, time: .omitted)) and \(endingDate.formatted(date: .complete, time: .omitted)) (inclusive).")
                        .fontWeight(.bold)
                        .padding(48)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
#if os(iOS)
            .background(colorMode == .light ? Color(UIColor.systemGray6) : Color(hue: 0, saturation: 0, brightness: 15/255))
#endif
            .tabItem {
                Text("Blocks Counter")
            }
        }
        .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
    }
    func blocksNameOfGivenDate(date: Date) -> [Int] {
        switch rotationOfDate(startDate: firstDayOfSchool, endDate: date) {
        case 1: return [0, 1, 2, 3]
        case 2: return [4, 5, 6, 7]
        case 3: return [1, 2, 3, 0]
        case 4: return [5, 6, 7, 4]
        case 5: return [2, 3, 0, 1]
        case 6: return [6, 7, 4, 5]
        case 7: return [3, 0, 1, 2]
        case 8: return [7, 4, 5, 6]
        default: return [-1]
        }
    }
    
    func blocksOfGivenRotation(block: Int) -> String {
        switch block {
        case 0: return "1A"
        case 1: return "2A"
        case 2: return "3A"
        case 3: return "4A"
        case 4: return "1B"
        case 5: return "2B"
        case 6: return "3B"
        case 7: return "4B"
        case 1055: return "EL"
        case 1500: return "After School"
        default: return "No School"
        }
    }
    
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
    
    func schoolDaysWithinDateRange(block: Int, startDate: Date, endDate: Date) -> Int {
        if Calendar.current.startOfDay(for: startDate) > Calendar.current.startOfDay(for: endDate) {
            return -1
        }
        var numberOfClasses = 0
        let dateRange = Date.dates(from: startingDate, to: endingDate)
        
        if 0...3 ~= block { // ~= means "contains"
            for day in dateRange {
                if rotationOfDate(startDate: firstDayOfSchool, endDate: day) % 2 == 1 {
                    numberOfClasses += 1
                }
            }
        }
        else if 4...7 ~= block {
            for day in dateRange {
                if rotationOfDate(startDate: firstDayOfSchool, endDate: day) % 2 == 0 {
                    numberOfClasses += 1
                }
            }
        }
        return numberOfClasses
    }
}
