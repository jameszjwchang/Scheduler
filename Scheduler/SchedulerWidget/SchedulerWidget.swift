//
//  SchedulerWidget.swift
//  SchedulerWidget
//
//  Created by James Chang on 8/1/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        // Provide a snapshot of the current schedule
        let entry = ScheduleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> ()) {
            var entries: [ScheduleEntry] = []

            let currentDate = Date()
            let calendar = Calendar.current
                
        for hourOffset in 0..<24 {
            if let entryDate = calendar.date(byAdding: .hour, value: hourOffset, to: currentDate) {
                let entry = ScheduleEntry(date: entryDate)
                entries.append(entry)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ScheduleEntry: TimelineEntry {
    let date: Date
}

struct SchedulerWidgetEntryView : View {
    var entry: Provider.Entry

    @AppStorage("firstDayOfSchool") var firstDayOfSchool: Date = Calendar.current.startOfDay(for: Date())
    @AppStorage("BreakDays") var BreakDays: [Date] = []
    @AppStorage("Blocks") var Blocks: [String] = ["", "", "", "", "", "", "", ""]
    @AppStorage("breakDaysMode") var breakDaysMode = 0

    var body: some View {
        VStack {
            if breakDaysMode == 0 {
                Text("Testing this should work!")
            }
            if rotationOfDate(startDate: firstDayOfSchool, endDate: Date()) != -1 {
                Text("Your schedule for today:").bold().padding(.bottom, 8)
                Grid {
                    ForEach(0 ..< 4) { block in
                        Spacer()
                        GridRow {
                            Text("**\(blocksOfGivenRotation(block: blocksNameOfGivenDate(date: Date())[block]))**:")
                            Text("\(Blocks[blocksNameOfGivenDate(date: Date())[block]])")
                        }
                        .gridColumnAlignment(.leading)
                        Spacer()
                    }
                }
            }
            else {
                Spacer()
                Text("No school on\nthis day!")
                    .bold()
                Spacer()
            }
        }
        .padding()
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
            if Calendar.current.startOfDay(for: presetFirstDayOfSchool()) > Calendar.current.startOfDay(for: endDate) || presetBreakDays().contains(Calendar.current.startOfDay(for: endDate)) || Calendar.current.isDateInWeekend(endDate) {
                return -1
            }
            for day in dateRange {
                if Calendar.current.isDateInWeekend(day) || presetBreakDays().contains(Calendar.current.startOfDay(for: day)) {
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
    
    func presetFirstDayOfSchool() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.date(from: "2024-08-13")!
    }
    
    func presetBreakDays() -> [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateStringArray = [
            "2024-08-13",
            "2024-09-16",
            "2024-09-16",
            "2024-09-17",
            "2024-09-30",
            "2024-10-01",
            "2024-10-02",
            "2024-10-03",
            "2024-10-04",
            "2024-10-15",
            "2024-11-07",
            "2024-11-08",
            "2024-11-29",
            "2024-12-19",
            "2024-12-20",
            "2024-12-23",
            "2024-12-24",
            "2024-12-25",
            "2024-12-26",
            "2024-12-27",
            "2024-12-30",
            "2024-12-31",
            "2025-01-01",
            "2025-01-02",
            "2025-01-03",
            "2025-01-27",
            "2025-01-28",
            "2025-01-29",
            "2025-01-30",
            "2025-01-31",
            "2025-02-03",
            "2025-02-04",
            "2025-03-21",
            "2025-03-31",
            "2025-04-01",
            "2025-04-02",
            "2025-04-03",
            "2025-04-04",
            "2025-04-14",
            "2025-05-01",
            "2025-05-02",
            "2025-05-30",
        ]

        return dateStringArray.compactMap { dateString in
            dateFormatter.date(from: dateString)
        }
    }
}

extension Date {
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

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()

    public var rawValue: String {
        Date.formatter.string(from: self)
    }

    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}

extension Array: RawRepresentable where Element: Codable {
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

struct SchedulerWidget: Widget {
    let kind: String = "SchedulerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SchedulerWidgetEntryView(entry: entry)
                .containerBackground(.thinMaterial, for: .widget)
        }
        .configurationDisplayName("Daily Schedule")
        .description("Displays your daily schedule.")
    }
}

#Preview(as: .systemMedium) {
    SchedulerWidget()
} timeline: {
    ScheduleEntry(date: .now)
}

