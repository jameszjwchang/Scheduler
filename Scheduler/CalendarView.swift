//
//  CalendarView.swift
//  Scheduler
//
//  Created by Hawkanesson on 12/2/22.
//

import Foundation
import SwiftUI
import SwiftUIIntrospect

struct Event: Identifiable, Hashable, Codable {
    let id: String
    var name: String
    var detail: String
    var date: Date
}

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("Events") var Events: [Event] = []
    
    @State var newEvent: Event = Event(id: UUID().uuidString, name: "", detail: "", date: Date())
    @State var DatePopover = false
    
    @State var width: CGFloat = 540
    @State var height: CGFloat = 62
    
    @FocusState private var focusedField: Bool?
    
    var body: some View {
        VStack {
#if os(iOS) || os(visionOS)
            VStack {
                HStack {
                    DatePicker("", selection: $newEvent.date)
                        .labelsHidden()
                    Spacer()
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
                HStack {
                    TextField("Event title", text: $newEvent.name)
                        .padding(2)
                        .fontWeight(.bold)
                    Button(action: {
                        Events.append(newEvent)
                            dismiss()
                    }, label: {
                        Image(systemName: "calendar.badge.plus")
                    })
                    .disabled(newEvent.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .animation(.snappy, value: newEvent.name)
                    .buttonStyle(BorderedButtonStyle())
                }
                ZStack {
                    TextEditor(text: .constant("Event detail"))
                        .opacity(newEvent.detail.isEmpty ? 0.2 : 0)
                    TextEditor(text: $newEvent.detail)
                        .scrollContentBackground(.hidden)
                }
                Spacer()
            }
#elseif os(macOS)
            HStack {
                TextField("Press return to save event.", text: $newEvent.name)
                    .font(.system(size: 18, weight: .semibold))
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: true)
                    .onAppear {
                        focusedField = true
                    }
                Button(action: {
                    height = height == 62 ? 240 : 62
                }, label: {
                    Image(systemName: height == 62 ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                        .frame(width: 30, height: 30)
                })
                Button(action: {
                    DatePopover.toggle()
                }) {
                    Text(formatDate(date: newEvent.date, format: "MMM d YYYY")).frame(width: 90, height: 30)
                }
                .popover(isPresented: $DatePopover) {
                    VStack {
                        DatePicker(selection: $newEvent.date, displayedComponents: .date) {}
                            .datePickerStyle(GraphicalDatePickerStyle())
                        DatePicker(selection: $newEvent.date, displayedComponents: .hourAndMinute) {}
                    }
                    .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                    .frame(width: 156, height: 204)
                }
                Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                        .frame(width: 58, height: 30)
                })
                Button(action: {
                    Events.append(newEvent)
                        dismiss()
                }, label: {
                    Image(systemName: "calendar.badge.plus")
                        .frame(width: 30, height: 30)
                        .opacity(newEvent.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 1)
                })
                .keyboardShortcut(.return, modifiers: [])
                .disabled(newEvent.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .animation(.smooth, value: newEvent.name)
            }
            .buttonStyle(ModernButtonStyle())
#endif
            
            #if os(macOS)
            if height != 62 {
                ZStack {
                    TextEditor(text: .constant(newEvent.detail.isEmpty ? "Event detail" : ""))
                        .foregroundStyle(.tertiary)
                    TextEditor(text: $newEvent.detail)
                        .scrollDisabled(newEvent.detail.isEmpty)
                }
                .padding(-4)
            }
            #endif
        }
        .padding()
        #if os(macOS)
        .background(ModernBackground(radius: 9)
            .frame(width: 540, height: 600))
        .frame(width: width, height: height)
        #endif
    }
}

struct EventView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    
    @AppStorage("Events") var Events: [Event] = []
    
    @State private var showAlert = false
    @State private var showContent = false
    
    @Binding var event: Event
    
    var body: some View {
        Text(event.name)
            .opacity(event.name.isEmpty ? 0.3 : 1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(EdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2))
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .foregroundStyle(chosenTint)
                    .opacity(0.2)
            )
            .padding(.horizontal, 1)
            .onTapGesture {
                showContent = true
            }
            .popover(isPresented: $showContent, content: {
                VStack {
                    TextField("Event name", text: $event.name)
                        .textFieldStyle(ModernTextFieldStyle())
                        .textFieldStyle(.plain)
                    ZStack {
                        TextEditor(text: .constant("Event description")).opacity(event.detail.isEmpty ? 0.3 : 0)
                        TextEditor(text: $event.detail)
                    }
                    .padding(.horizontal, 2)
                    .padding(.vertical, 4)
                    .background(ModernBackground())
                    Button("Delete Event") {
                        showAlert = true
                    }
                }
                .padding()
                .frame(width: 250, height: 300)
            })
            .alert("Delete this event?", isPresented: $showAlert) {
                HStack {
                    Button("Yes") {
                        DispatchQueue.main.async {
                            Events.removeAll(where: {$0 == event})
                        }
                    }
                    Button("No") {}
                }
            }
    }
}

struct CalendarView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("firstDayOfSchool") var SchoolyearStartingDay: Date = Date().onlyDate!
    @AppStorage("Events") var Events: [Event] = []

    @State var currentMonth = 0
    let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    @Environment(\.dismiss) var dismiss
    @State var currentTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @State var updatingDate = Date()
    @State var addEvent = false
    
    @State var selectedAddButton = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
    
//    @State var displayOverlay = false

    var body: some View {
        let CalendarMonth = Calendar.current.date(byAdding: .month, value: currentMonth, to: updatingDate)!
        VStack(spacing: 0) {
            HStack {
                Text("\(formatDate(date: CalendarMonth, format: "MMMM YYYY")) ")
                    .bold()
                    .font(.system(size: 18))
                #if os(macOS)
                    .fontWeight(.bold)
                #endif
                Spacer()
                HStack {
                    Button(action: {
                        withAnimation(.linear(duration: 0.1)) {currentMonth -= 1}
                    }) {Image(systemName: "chevron.left").fontWeight(.bold)}
                    
                    Button {
                        withAnimation(.snappy(duration: 0.3, extraBounce: 0.32)) {
                            currentMonth = 0
                        }
                    } label: {
                        Image(systemName: "smallcircle.filled.circle")
                            .fontWeight(.bold)
                    }
                    .disabled(currentMonth == 0)
                    .padding(.horizontal, 12)
                    
                    Button(action: {
                        withAnimation(.linear(duration: 0.1)) {currentMonth += 1}
                    }) {Image(systemName: "chevron.right").fontWeight(.bold)}
                }
                #if os(macOS)
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                #endif
                Button(action: {
                    addEvent = true
                }) {
                    Image(systemName: "calendar.badge.plus")
                        .frame(width: 30, height: 30)
                }
                .sheet(isPresented: $addEvent) {
                    AddEventView()
                }
                #if os(macOS)
                .buttonStyle(ModernButtonStyle())
                
                #endif
//                Button(action: {
//                    displayOverlay = true
//                }) {
//                    Text("Overlay")
//                }
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(0 ..< 7) { days in
                            Text("\(daysOfWeek[days])").frame(width: geometry.size.width/7, height: geometry.size.height/7)
                        }
                    }
                    ForEach(0 ..< 6) { weeks in
                        HStack(spacing: 0) {
                            ForEach(0 ..< 7) { days in
                                let CalendarMonth = Calendar.current.date(byAdding: .month, value: currentMonth, to: updatingDate)!
                                let FirstDayOfMonth = Calendar.current.date(byAdding: .day, value: -Calendar.current.component(.day, from: CalendarMonth) + 1, to: CalendarMonth)!
                                let DisplayedDay = Calendar.current.date(byAdding: .day, value: weeks*7+days - Calendar.current.component(.weekday, from: FirstDayOfMonth) + 1, to: FirstDayOfMonth)!
                                
                                VStack(spacing: 0) {
                                    Text("\(Calendar.current.component(.day, from: DisplayedDay))")
                                        .foregroundStyle(DisplayedDay == updatingDate ? chosenTint : .primary)
                                        .opacity(Calendar.current.component(.month, from: DisplayedDay) == Calendar.current.component(.month, from: CalendarMonth) ? 1 : 0.3)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(3)
                                    
                                    ScrollView {
                                        ForEach($Events) { $event in
                                            if event.date.onlyDate! ==  DisplayedDay.onlyDate! {
                                                EventView(event: $event)
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width/7, height: geometry.size.height/7, alignment: .topLeading)
                                .border(.primary.opacity(0.04), width: 1)
                            }
                        }
                    }
                    .border(.primary.opacity(0.08), width: 1)
                }
            }
            #if os(macOS)
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
            #endif
        }
//                HStack {
//                    TextField(text: $zoomLink)
//                    //green for working and red for not working
//                    Button(action: {
//                        
//                    }, label: {
//                        
//                    })
//                }
        #if os(macOS)
        .navigationTitle("Calendar")
        #endif
        .onReceive(currentTimer) { _ in
            updatingDate = Date()
        }
//        .overlay {
//            if displayOverlay {
//                ZStack {
//                    Rectangle()
//                        .opacity(0.8)
//                    Rectangle()
//                        .frame(width: 200, height: 200)
//                        .opacity(0.7)
//                        .onTapGesture {
//                            displayOverlay = false
//                        }
//                        .border(.primary, width: 0.5)
//                }
//            }
//        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}

//#Preview {
//    CalendarView()
//}
