//
//  SetupView.swift
//  Scheduler
//
//  Created by Hawkanesson on 12/26/22.
//

import SwiftUI

struct SetupView: View {
    @AppStorage("chosenTint") var chosenTint: Color = .red

    @Environment(\.dismiss) var dismiss
    
    @AppStorage("Blocks") var Blocks: [String] = ["", "", "", "", "", "", "", ""]
    
    @AppStorage("firstDayOfSchool") var firstDayOfSchool: Date = Date().onlyDate!
    
    @AppStorage("IntroSetup") var IntroSetup = true
    
    
    
    #if os(macOS)
    @State var DatePopover = false
    #endif
    
    var body: some View {
        VStack {
            #if os(iOS)
            Section(header:
                Text("Welcome to Scheduler!")
                    .font(.system(size: 24))
                    .foregroundColor(chosenTint)
                    .fontWeight(.bold)
                    .listRowBackground(Color.clear)
                    .padding(.top)
                    .padding(.vertical)
                    .textCase(nil)
                    .frame(maxWidth: .infinity)
            ) {
                DatePicker("First Day of School:", selection: $firstDayOfSchool, displayedComponents: [.date])
            }
            #endif
            
            #if os(macOS)
            Text("Welcome to Scheduler!")
                .font(.system(size: 24))
                .foregroundColor(chosenTint)
                .fontWeight(.bold)
            HStack {
                Text("First Day of School:")
                Spacer()
                Button(action: {
                    DatePopover.toggle()
                }) {
                    Text("\(formatDate(date: firstDayOfSchool, format: "MMM d YYYY"))")
                        .frame(width: 90, height: 30)
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
            }
            .padding(.horizontal)
            #endif
            Text("Classes").bold()
            VStack {
                TextField("1A Block", text: $Blocks[0])
                TextField("2A Block", text: $Blocks[1])
                TextField("3A Block", text: $Blocks[2])
                TextField("4A Block", text: $Blocks[3])
                TextField("1B Block", text: $Blocks[4])
                TextField("2B Block", text: $Blocks[5])
                TextField("3B Block", text: $Blocks[6])
                TextField("4B Block", text: $Blocks[7])
            }
            .padding(.horizontal)
            
            Text("Note: all break days during the school year must be selected in order for the app to show the correct schedule; this only takes around a minute to complete.").foregroundColor(chosenTint).font(.system(size: 12))
            Button(action: {
                dismiss()
            }, label: {
                Text("Done")
                    .padding(5)
            })
        }
        #if os(macOS)
        .padding()
        .frame(width: 408, height: 540)
        .textFieldStyle(ModernTextFieldStyle())
        .textFieldStyle(.plain)
        #endif
        .onAppear {
            if IntroSetup {
                firstDayOfSchool = Date().onlyDate!
            }
        }
    }
}

struct SetupView_Previews: PreviewProvider {
    static var previews: some View {
        SetupView()
    }
}
        
