//
//  MenuBarView.swift
//  Scheduler
//
//  Created by Hawkanesson on 12/2/22.
//

import Foundation
import SwiftUI

struct MenuBarView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    @Environment(\.colorScheme) var colorMode
    
    @AppStorage("firstDayOfSchool") var firstDayOfSchool: Date = Calendar.current.startOfDay(for: Date())
    @AppStorage("BreakDays") var BreakDays: [Date] = []
    @AppStorage("Blocks") var Blocks: [String] = ["", "", "", "", "", "", "", ""]
    
    @State var currentTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @State var updatingDate = Date()
    
    @State var SelectedDay = Calendar.current.startOfDay(for: Date())
    
    @AppStorage("breakDaysMode") var breakDaysMode = 0
    @State private var loadedPresetBreakDays: [Date] = presetBreakDays()

    var body: some View {
        VStack {
            HStack {
                Button {
                    withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {
                        SelectedDay = Calendar.current.date(byAdding: .day, value: -1, to: SelectedDay)!
                    }
                } label: {
                    Image(systemName: "chevron.left").contentShape(Circle())
                }
                .padding(.leading, 4)
                Divider()
                Button("Today") {
                    withAnimation(.snappy(duration: 0.3, extraBounce: 0.32)) {
                        SelectedDay = Date().onlyDate!
                    }
                }
                .disabled(SelectedDay == Date().onlyDate!)
                .animation(nil, value: true)
                Divider()
                Button {
                    withAnimation(.snappy(duration: 0.2, extraBounce: 0.32)) {
                        SelectedDay = Calendar.current.date(byAdding: .day, value: 1, to: SelectedDay)!
                    }
                } label: {
                    Image(systemName: "chevron.right").contentShape(Circle())
                }
                .padding(.trailing, 4)
            }
            .fontWeight(.bold)
            .buttonStyle(.plain)
            .padding(8)
            .glass(cornerRadius: (12.0, 12.0), shadowRadius: (3, 3))
            .frame(height: 28)
            .padding(.bottom, 8)
            Text("\(formatDate(date: SelectedDay, format: "MMM d, YYYY"))")
                .fontWeight(.bold)
                .font(.title3)
                .padding(.horizontal)
                .padding(.bottom, 4)
            if rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay) != -1 {
                (Text(rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay) % 2 == 1 ? "A" : "B") + Text(" day (Rotation \(rotationOfDate(startDate: firstDayOfSchool, endDate: SelectedDay)))")).font(.callout).bold().padding(.bottom, 8)
                Grid {
                    ForEach(0 ..< 4) { block in
                        Spacer()
                        GridRow {
                            Text("**\(blocksOfGivenRotation(block: blocksNameOfGivenDate(date: SelectedDay)[block]))**:")
                            Text("\(Blocks[blocksNameOfGivenDate(date: SelectedDay)[block]])")
                        }
                        .gridColumnAlignment(.leading)
                        .font(.callout)
                        Spacer()
                    }
                }
            }
            else {
                Spacer()
                Text("No school on\nthis day!")
                    .bold().font(.callout)
                Spacer()
            }
        }
        .padding()
        .onReceive(currentTimer) { _ in
            if Calendar.current.startOfDay(for: updatingDate) != Calendar.current.startOfDay(for: Date()) {
                SelectedDay = Calendar.current.startOfDay(for: updatingDate)
            }
            updatingDate = Date()
        }
        .onAppear {
            SelectedDay = Calendar.current.startOfDay(for: Date())
        }
        .frame(width: 168, height: 288)
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
}
