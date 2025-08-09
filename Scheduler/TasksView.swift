//
//  TasksView.swift
//  Scheduler
//
//  Created by James Chang on 2023/7/4.
//

//
//  EventsView.swift
//  Scheduler
//
//  Created by Hawkanesson on 11/3/22.
//

import Foundation
import SwiftUI
import SwiftUIIntrospect
import UserNotifications

struct Item: Identifiable, Hashable, Codable {
    let id: String
    var title: String
    var detail: String
    var due: Date
    let type: Bool
}

struct EditView: View {
    @Binding var task: Item
    
    @State var editedTask: Item = Item(id: "", title: "", detail: "", due: Date(), type: true)
    
    @AppStorage("TasksList") var TasksList: [Item] = []
    @AppStorage("SortTasks") var SortTasks = true
    @AppStorage("SortEvents") var SortEvents = true
    
    @Environment(\.dismiss) var dismiss
    
    #if os(macOS)
    @FocusState private var focusedField: Bool?
    @State private var DatePopover = false
    #endif

    var body: some View {
        VStack {
            VStack {
                #if os(iOS) || os(visionOS)
                TextField("Add a title", text: $editedTask.title, axis: .vertical)
                    .bold()
                    .padding(.vertical, 8)
                #elseif os(macOS)
                TextField("Add a title", text: $editedTask.title)
                    .font(.system(size: 16, weight: .bold))
                    .focused($focusedField, equals: true)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 4)
                #endif
                Divider().foregroundStyle(.primary)
                #if os(iOS) || os(visionOS)
                GeometryReader { geo in
                    TextField("Add a description", text: $editedTask.detail, axis: .vertical)
                        .padding(.vertical, 8)
                }
                #elseif os(macOS)
                ZStack {
                    TextEditor(text: .constant(editedTask.detail.isEmpty ? "Add a description" : "")).foregroundStyle(.tertiary)
                    TextEditor(text: $editedTask.detail)
                }
                .font(.system(size: 13))
                .scrollIndicators(.never)
                #endif
                Divider().foregroundColor(.primary)
                HStack {
                    #if os(iOS) || os(visionOS)
                    DatePicker(selection: $editedTask.due) {}
                        .labelsHidden()
                    #elseif os(macOS)
                    Button(action: {
                        DatePopover.toggle()
                    }) {
                        Text(formatDate(date: editedTask.due, format: "MMM d YYYY"))
                            .frame(width: 90, height: 30)
                    }
                    .buttonStyle(ModernButtonStyle())
                    .popover(isPresented: $DatePopover) {
                        VStack {
                            DatePicker(selection: $editedTask.due, displayedComponents: .date) {}
                                .datePickerStyle(GraphicalDatePickerStyle())
                            DatePicker(selection: $editedTask.due, displayedComponents: .hourAndMinute) {}
                        }
                        .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                        .frame(width: 156, height: 204)
                    }
                    #endif
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("Save")
                        #if os(macOS)
                            .padding(6)
                        #endif
                    })
                    .buttonStyle(BorderedProminentButtonStyle())
                }
            }
            .padding()
            #if os(macOS)
            .frame(width: 504, height: 480)
            #endif
        }
        .onAppear {
            editedTask = task
        }
        .onDisappear {
            task = editedTask
            if SortTasks {
                TasksList.sort {
                    $0.due < $1.due
                }
            }
        }
    }
}

struct EntryView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    
    @AppStorage("taskTitle") var taskTitle = ""
    @AppStorage("taskDetail") var taskDetail = ""
    @State var taskDate: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
    
    @AppStorage("SortTasks") var SortTasks = true
    @AppStorage("TasksList") var TasksList: [Item] = []
    
    #if os(iOS) || os(visionOS)
    @Binding var addTask: Bool
    @State private var toggleField = false
    #endif
    
    @Binding var toggleScroll: Bool
    
    #if os(macOS)
    @State private var showDetail = false
    @FocusState private var focusedField: Bool?
    @State private var DatePopover = false
    #endif
    
    var body: some View {
        VStack {
#if os(iOS) || os(visionOS)
            HStack {
                TextField("Press \"+\" or press return to add task.", text: $taskTitle, onCommit: addTaskToList)
                    .bold()
                    .introspect(.textField, on: .iOS(.v16, .v17)) { textField in
                        DispatchQueue.main.async {
                            if !toggleField {
                                textField.becomeFirstResponder()
                                toggleField = true
                            }
                        }
                    }
                Button(action: {
                    addTaskToList()
                }) {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .fontWeight(.semibold)
                }
                .disabled(taskTitle.isEmpty)
                .buttonStyle(BorderedProminentButtonStyle())
                .clipShape(Capsule())
                .shadow(color: (taskTitle.isEmpty ? .clear : chosenTint), radius: 4)
            }
            Divider()
            TextField("Add a description", text: $taskDetail, axis: .vertical)
                .lineLimit(5)
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)
            Spacer()
            DatePicker(selection: $taskDate) {}
                .labelsHidden()
#elseif os(macOS)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    TextField("Press enter to save task.", text: $taskTitle)
                        .fontWeight(.semibold)
                        .font(.system(size: 14))
                        .focused($focusedField, equals: true)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onAppear {
                            focusedField = true
                        }
                        .focused($focusedField, equals: true)
                        .padding(.leading, 8)
                    Button(action: {
                        withAnimation(.smooth(duration: 0.3)) {
                            showDetail.toggle()
                        }
                    }) {
                        Image(systemName: showDetail ? "xmark" : "arrow.up.left.and.arrow.down.right")
                            .frame(width: 30, height: 30)
                    }
                    .frame(width: showDetail ? 30 : 30, height: 30)
                    .buttonStyle(ModernButtonStyle())
                    .padding(.horizontal, 6)
                    Button(action: {
                        DatePopover.toggle()
                    }) {
                        Text(formatDate(date: taskDate, format: "MMM d YYYY"))
                            .frame(width: 90, height: 30)
                    }
                    .buttonStyle(ModernButtonStyle())
                    .popover(isPresented: $DatePopover) {
                        VStack {
                            DatePicker(selection: $taskDate, displayedComponents: .date) {}
                                .datePickerStyle(GraphicalDatePickerStyle())
                            DatePicker(selection: $taskDate, displayedComponents: .hourAndMinute) {}
                        }
                        .padding(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                        .frame(width: 156, height: 204)
                    }
                    .padding(.trailing, 6)
                        Button(action: {
                            addTaskToList()
                        }) {
                            Image(systemName: "arrowshape.zigzag.right")
                                .scaleEffect(1.1)
                                    .opacity(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.3 : 1)
                                    .frame(width: 30, height: 30)
                        }
                        .buttonStyle(ModernButtonStyle())
                        .keyboardShortcut(.return, modifiers: [])
                        .disabled(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                if showDetail {
                    ZStack {
                        TextEditor(text: .constant(taskDetail.isEmpty ? "Enter a description" : ""))
                            .font(.system(size: 13))
                            .frame(minHeight: 60, maxHeight: 108)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                            .opacity(0.3)
                            .scrollIndicators(.never)
                        TextEditor(text: $taskDetail)
                            .font(.system(size: 13))
                            .frame(minHeight: 60, maxHeight: 108)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(6)
            .glass(cornerRadius: (10, 10))
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
            Divider().padding(.horizontal)
            #endif
        }
    }
    
    func addTaskToList() {
        DispatchQueue.main.async {
            if !taskTitle.isEmpty {
                withAnimation(.smooth(duration: 0.5)) {
                    TasksList.insert(Item(id: UUID().uuidString, title: taskTitle, detail: taskDetail, due: taskDate, type: true), at: 0)
                    taskTitle = ""
                    taskDetail = ""
                    taskDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
#if os(macOS)
                    showDetail = true
                    showDetail = false
#endif
                    if SortTasks {
                        TasksList.sort {
                            $0.due < $1.due
                        }
                    }
                }
#if os(iOS)
                addTask = false
                let impactHeavy = UIImpactFeedbackGenerator(style: .medium)
                impactHeavy.impactOccurred()
#endif
                toggleScroll.toggle()
            }
        }
    }
}

struct TaskRow: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var TasksList: [Item]
    @Binding var Completed: [Item]
    @Binding var item: Item
    
    @State var editTask = false
    @State var strikethroughEnabled = false
    
    #if os(macOS)
    @State var hoverOnEdit = false
    #endif
    
    @State var completedTask = false
    
    // BUTTON STUFF
    @State var buttonPressedDown = false
    @State var buttonHover = false
    //

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 1.5)
                    .frame(width: 15, height: 15)
                    .opacity(0.75)
                RoundedRectangle(cornerRadius: 5)
                    .stroke(lineWidth: 1.5)
                    .frame(width: 15, height: 15)
                    .scaleEffect(buttonHover ? 0.85 : 1)
                    .opacity(0.75)
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 15, height: 15)
                    .opacity(buttonPressedDown ? 0.15 : 0)
                Image(systemName: "checkmark")
                    .frame(width: 15, height: 15)
                    .bold()
                #if os(iOS)
                    .scaleEffect(0.75)
                #elseif os(macOS)
                    .scaleEffect(0.9)
                #endif
                    .opacity(completedTask ? 1 : 0)
            }
            .opacity(buttonPressedDown ? 0.85 : 1)
            .foregroundColor(item.due < Date() ? .red : (item.due.onlyDate! == Date().onlyDate! ? .yellow : .green))
            .frame(width: 15, height: 15)
            .shadow(color: item.due < Date() ? .red.opacity(0.6) : (item.due.onlyDate! == Date().onlyDate! ? Color.yellow : Color.green).opacity(0.5), radius: 2)
            .brightness(-0.05)
#if os(iOS)
            .scaleEffect(1.3)
#endif
        #if os(iOS)
            .padding(.trailing)
        #elseif os(macOS)
            .padding(.horizontal, 12)
        #endif
            .onHover { hover in
                buttonHover = hover
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                .onChanged({ gesture in
                    if sqrt(pow(gesture.translation.height, 2) + pow(gesture.translation.width, 2)) < 20 {
                        buttonPressedDown = true
                    }
                    else {
                        buttonPressedDown = false
                    }
                })
                .onEnded({ gesture in
                
                    if sqrt(pow(gesture.translation.height, 2) + pow(gesture.translation.width, 2)) < 20 {
                        buttonHover = false
                        buttonPressedDown = false
#if os(iOS)
                        let haptic = UINotificationFeedbackGenerator()
                        haptic.notificationOccurred(.success)
#endif
                        withAnimation(.smooth(duration: 0.2)) {
                            if completedTask {
                                TasksList.insert(item, at: 0)
                                Completed.removeAll(where: {$0 == item})
                            }
                            else {
                                Completed.insert(item, at: 0)
                                TasksList.removeAll(where: {$0 == item})
                            }
                        }
                    }
                })
            )
            .animation(.smooth(duration: 0.2), value: buttonHover)
            
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(strikethroughEnabled ? .secondary : .primary)
                        if item.detail != "" {
                            Text(item.detail)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .strikethrough(strikethroughEnabled, color: .primary.opacity(completedTask ? 1 : 0.6))
                    Spacer()
                    VStack {
#if os(iOS) || os(visionOS)
                        Text(formatDate(date: item.due, format: "MMM dd"))
                        Text(formatDate(date: item.due, format: "HH mm"))
#elseif os(macOS)
                        Text(formatDate(date: item.due, format: "MMM dd HH mm"))
#endif
                    }
                    .foregroundColor(item.due < Date() ? .red : (item.due.onlyDate! == Date().onlyDate! ? .yellow : .green))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.trailing, 12)
                }
#if os(iOS) || os(visionOS)
                .contentShape(Rectangle())
#endif
#if os(macOS)
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                .background(Rectangle().foregroundStyle(.primary.opacity(0.0001)))
#endif
                .opacity(completedTask ? 0.5 : 1)
            if completedTask {
                Button{
                    withAnimation {
                        Completed.removeAll(where: { $0 == item })
                    }
                } label: {
                    Image(systemName: "delete.left")
                }
                .buttonStyle(BorderedButtonStyle())
                .padding(.trailing, 8)
            }
        }
        .moveDisabled(completedTask)
        #if os(iOS) || os(visionOS)
        .sheet(isPresented: $editTask) {
            EditView(task: $item)
        }
        #elseif os(macOS)
        .listRowSeparator(.hidden)
        .background(ModernBackground(radius: 9).opacity(0.75))
        .sheet(isPresented: $editTask) {
            EditView(task: $item)
        }
        .onHover { hover in
            withAnimation(.smooth(duration: 0.15)) {
                hoverOnEdit = hover
            }
        }
        #endif
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if !completedTask {
                Button {
                    editTask = true
                } label: {
                    Label("Edit", systemImage: "slider.horizontal.3")
                }
                #if os(iOS)
                .tint(Color(uiColor: .darkGray))
                #elseif os(macOS)
                .tint(Color(nsColor: .darkGray))
                #endif
                
                Button {
                    withAnimation(.smooth(duration: 0.2)) {
                        Completed.insert(item, at: 0)
                        TasksList.removeAll(where: {$0 == item})
                    }
                } label: {
                    Label("Complete", systemImage: "checkmark")
                }
                .tint(.green)
            }
        }
    }
}

struct TasksView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    
    #if os(iOS) || os(visionOS)
    @Environment(\.colorScheme) var colorMode
    #endif
    
    @AppStorage("TasksList") var TasksList: [Item] = []
    @AppStorage("Completed") var Completed: [Item] = []

    #if os(iOS) || os(visionOS)
    @State var addTask = false
    @State private var selectedAddButton = false
    #endif
    @State var editing: Item = Item(id: "", title: "", detail: "", due: Date(), type: true)
    
    @State var currentTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    @State var date = Date().onlyDate!

    @State private var toggleForScrollingDownList = true
    @State private var showAlert = false

    var body: some View {
        ZStack {
            VStack {
                #if os(macOS)
                EntryView(toggleScroll: $toggleForScrollingDownList)
                #endif

                ScrollViewReader { scrollView in
                    List {
                        Section {
                            if TasksList.isEmpty {
                                Text("Add some tasks to complete ~")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                                #if os(macOS)
                                    .padding(.horizontal, 32)
                                #endif
                                    .padding(.vertical, 12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .opacity(0.05)
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [10, 5]))
                                            .opacity(0.4)
                                    )
                            }
                        }
                        .frame(maxHeight: TasksList.isEmpty ? 120 : 0)
                        .id("firstElement")
                        .listRowSeparator(.hidden)
                        #if os(iOS)
                        .listRowBackground(Color.clear)
                        #endif

                        Section {
                            withAnimation(.smooth(duration: 0.2)) {
                                ForEach($TasksList, id: \.self, editActions: [.move]) { $item in
                                    TaskRow(TasksList: $TasksList, Completed: $Completed, item: $item)
                                }
                            }
                        }
                        if !Completed.isEmpty {
                            Section {
                                Button("Clear All Completed") {
                                    showAlert.toggle()
                                }
                                .frame(maxWidth: .infinity)
                                .buttonStyle(.borderedProminent)

                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                
                                VStack(spacing: 0) {
                                    ForEach($Completed) { $complete in
                                        TaskRow(TasksList: $TasksList, Completed: $Completed, item: $complete, strikethroughEnabled: true, completedTask: true)
                                            .padding(.vertical, 4)
                                    }
                                    .animation(.smooth(duration: 0.2), value: TasksList)
                                    .alert("Clear the entire list?", isPresented: $showAlert) {
                                        HStack {
                                            Button("Yes") {
                                                withAnimation {
                                                    Completed.removeAll()
                                                }
                                            }
                                            Button("No") {}
                                        }
                                    }
                                }
                                .listRowBackground(Color.clear)
                                #if os(iOS)
                                .background(RoundedRectangle(cornerRadius: 12).padding(EdgeInsets(top: -6, leading: -16, bottom: -6, trailing: -16)).opacity(0.02))
                                #endif
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .onChange(of: toggleForScrollingDownList) {
                        withAnimation(.smooth) {
                            scrollView.scrollTo("firstElement", anchor: .top)
                        }
                    }
#if os(iOS)
                .shadow(color: .primary.opacity(0.08), radius: 5)
                .listRowSpacing(9)
#endif
                }
            }
            
            #if os(iOS) || os(visionOS)
            Button(action: {
                addTask = true
                #if os(iOS)
                let impactHeavy = UIImpactFeedbackGenerator(style: .light)
                impactHeavy.impactOccurred()
                #endif
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .padding(8)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        selectedAddButton = true
                    }
                    .onEnded{ _ in
                        selectedAddButton = false
                    }
            )
            .buttonStyle(BorderedProminentButtonStyle())
            .clipShape(Circle())
            .shadow(color: chosenTint, radius: 5)
            .padding()
            .scaleEffect(selectedAddButton ? 0.9 : 1)
            .animation(.smooth, value: selectedAddButton)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .sheet(isPresented: $addTask) {
                EntryView(addTask: $addTask, toggleScroll: $toggleForScrollingDownList)
                .padding()
                .presentationDetents([.height(180)])
            }
            #endif
        }
        #if os(macOS)
        .navigationTitle("Tasks")
        #endif
        .onReceive(currentTimer) { _ in
            date = Date().onlyDate!
        }
        .onChange(of: TasksList.count) {
            #if os(iOS) || os(visionOS)
            UNUserNotificationCenter.current().setBadgeCount(TasksList.count)
//            UIApplication.shared.applicationIconBadgeNumber = TasksList.count
            #elseif os(macOS)
            if TasksList.count == 0 {
                NSApplication.shared.dockTile.badgeLabel = nil
            }
            else {
                NSApplication.shared.dockTile.badgeLabel = String(TasksList.count)
            }
            #endif
        }
    }
}

struct TaskPreviews: PreviewProvider {
    static var previews: some View {
        TasksView()
    }
}
