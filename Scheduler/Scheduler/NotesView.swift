//
//  NotesView.swift
//  Scheduler
//
//  Created by James Chang on 8/13/23.
//

import SwiftUI
import SwiftUIIntrospect

struct NoteView: View {
    @Binding var note: Note
    @State private var fullScreen = false
    
    var body: some View {
        VStack {
                Text(note.title.isEmpty ? "New Note" : note.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(note.content.isEmpty ? " " : note.content)
                .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            fullScreen = true
        }
        #if os(iOS) || os(visionOS)
        .fullScreenCover(isPresented: $fullScreen) {
            VStack {
                TextField("Title", text: $note.title)
                    .fontWeight(.bold)
                    .font(.title2)
                TextField("Content", text: $note.content, axis: .vertical)
                Spacer()
                Button("Done") {
                    fullScreen = false
                }
            }
            .padding()
        }
        #endif
    }
}

struct NotesView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("Notes") var Notes: [Note] = []
    @AppStorage("selectedNote") var selectedNote: [Note] = [Note(id: UUID().uuidString, dateCreated: Date(), dateModified: Date(), title: "", content: "")]
    @State private var toggleScroll = true
    @State private var contentFontSize: Double = 13
    
#if os(macOS)
    @Binding var backgroundOpacity: Double
#endif
    
    @State private var showAlert = false

    var body: some View {
        #if os(iOS) || os(visionOS)
        VStack {
            HStack {
                Text("Notes")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    withAnimation {
                        Notes.append(Note(id: UUID().uuidString, dateCreated: Date(), dateModified: Date(), title: "New Note", content: ""))
                        toggleScroll.toggle()
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                        .fontWeight(.semibold)
                        .padding(8)
                }
                .buttonStyle(ModernButtonStyle())
                if !Notes.isEmpty {
                    EditButton()
                }
//                Button("Clear") {
//                    Notes.removeAll()
//                }
            }
            .padding(.horizontal)
            ScrollViewReader { scrollView in
                if Notes.isEmpty {
                    Text("This is a place to write something down at a moment's notice, remember to make use of it!")
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(48)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    List($Notes, editActions: .all) { $note in
                        NoteView(note: $note)
                    }
                    .shadow(color: .primary.opacity(0.06), radius: 4)
                    .listRowSpacing(9)
                    .scrollContentBackground(.hidden)
                    .onChange(of: toggleScroll) {
                        withAnimation(.smooth) {
                            scrollView.scrollTo(Notes[Notes.endIndex - 1], anchor: .top)
                        }
                    }
                }
            }
            
        }
        #elseif os(macOS)
        VStack(spacing: 0) {
            if Notes.isEmpty {
                VStack {
                    Button {
                        Notes.append(Note(id: UUID().uuidString, dateCreated: Date(), dateModified: Date(), title: "", content: ""))
                        selectedNote[0] = Notes[Notes.endIndex - 1]
                        DispatchQueue.main.async {
                            withAnimation {
                                toggleScroll.toggle()
                            }
                        }
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 24, weight: .bold))
                            .padding(.vertical, 3)
                            .offset(y: -1)
                            .frame(width: 60, height: 60)
                    }
                    .buttonStyle(ModernButtonStyle(radius: 12))
                    .opacity(0.95)
                    Text("This is a place to write something down at a moment's notice, remember to make use of it!")
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                HStack(spacing: 0) {
                    GeometryReader { geometry in
                        ScrollViewReader { scrollView in
                            ScrollView(.horizontal) {
                                ZStack(alignment: .leading) {
                                    if let i = Notes.firstIndex(where: {$0.id == selectedNote.first!.id}) {
                                        chosenTint
                                            .opacity(0.8)
                                            .mask(RoundedRectangle(cornerRadius: 5, style: .continuous))
                                            .shadow(color: chosenTint, radius: 1)
                                            .frame(width: max(42, geometry.size.width / CGFloat(Notes.count)), height: 24)
                                            .offset(x: CGFloat(Notes.distance(from: Notes.startIndex, to: i))*max(42, geometry.size.width / CGFloat(Notes.count)))
                                            .animation(.smooth(duration: 0.15), value: selectedNote.first!)
                                    }
                                    HStack(spacing: 0) {
                                        ForEach($Notes, id: \.self) { $note in
                                            HStack(spacing: 0) {
                                                if let i = Notes.first, note != i {Divider().padding(.vertical, 5)}
                                                
                                                Spacer()
                                                Text(note.title.isEmpty ? "New Note" : note.title).foregroundStyle(Color(note.id == selectedNote[0].id ? NSColor.textBackgroundColor : NSColor.textColor))
                                                Spacer()
                                                
                                                if let j = Notes.last, note != j {Divider().padding(.vertical, 5)}
                                            }
                                            .contentShape(Rectangle())
                                            .frame(width: max(42, geometry.size.width / CGFloat(Notes.count)))
                                            .onTapGesture {selectedNote[0] = note}
                                            .id(note)
                                        }
                                        .animation(.smooth(duration: 0.15), value: selectedNote.first!)
                                    }
                                }
                                .padding(8)
                            }
                            .scrollIndicators(.never)
                            .onChange(of: toggleScroll) {
                                if !Notes.isEmpty {
                                    withAnimation(.bouncy) {
                                        scrollView.scrollTo(Notes[Notes.endIndex - 1], anchor: .leading)
                                    }
                                }
                            }
                            .padding(-8)
                        }
                    }
                    .padding(2)
                    .mask(RoundedRectangle(cornerRadius: 6.5))
                    .background(ModernBackground(radius: 6.5))
                    .frame(height: 28)
                    .padding(.leading, 12)
                    Button {
                        Notes.append(Note(id: UUID().uuidString, dateCreated: Date(), dateModified: Date(), title: "", content: ""))
                        selectedNote[0] = Notes[Notes.endIndex - 1]
                        DispatchQueue.main.async {
                            withAnimation {
                                toggleScroll.toggle()
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .semibold))
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(ModernButtonStyle(radius: 7))
                    .frame(width: 28, height: 28)
                    .padding(.horizontal, 8)
                }
                
                if Notes.count > 0 {
                    VStack {
                        if let note = Notes.firstIndex(where: {$0.id == selectedNote[0].id}) {
                            HStack {
                                TextField("Title", text: $Notes[note].title)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .textFieldStyle(.plain)
                                    .shadow(color: .black.opacity(1-backgroundOpacity), radius: 2, y: 2)
                                Button {
                                    showAlert.toggle()
                                } label: {
                                    Text("Delete Note")
                                        .fontWeight(.semibold)
                                        .padding(3)
                                }
                                .alert("Delete this note?", isPresented: $showAlert) {
                                    HStack {
                                        Button("Yes") {
                                            DispatchQueue.main.async {
                                                Notes.remove(at: note)
                                                if !Notes.isEmpty {
                                                    selectedNote[0] = Notes[Notes.endIndex - 1]
                                                }
                                                withAnimation {
                                                    toggleScroll.toggle()
                                                }
                                            }
                                        }
                                        Button("No") {}
                                    }
                                }
                            }
                            .padding(.bottom, 4)
                            ZStack {
                                TextEditor(text: .constant(Notes[note].content.isEmpty ? "Description" : ""))
                                    .foregroundStyle(.tertiary)
                                    .font(.system(size: contentFontSize))
                                    .padding(-4)
                                    .scrollContentBackground(.hidden)
                                TextEditor(text: $Notes[note].content)
                                    .font(.system(size: contentFontSize))
                                    .padding(-4)
                                    .scrollDisabled(Notes[note].content.isEmpty)
                                    .scrollContentBackground(.hidden)
                            }
                            .shadow(color: .black.opacity(1-backgroundOpacity), radius: 2, y: 2)
                        }
                    }
                    .foregroundStyle(colorScheme == .light ? backgroundOpacity < 1 ? .white : .black : .white)
                    .padding()
                }
                HStack {
                    Slider(value: $backgroundOpacity, in: 0...1) {
                        Text("Window Opacity: ")
                    }.padding()
                    Text("Font Size: ")
                    Slider(value: $contentFontSize, in: 10...40, step: 3)
                    .frame(width: 150).padding()
                    Text(String(contentFontSize))
                }
            }
        }
        .navigationTitle("Notes")
        #endif
    }
}

#Preview {
    #if os(iOS) || os(visionOS)
    NotesView()
    #elseif os(macOS)
    NotesView(backgroundOpacity: .constant(1))
    #endif
}
