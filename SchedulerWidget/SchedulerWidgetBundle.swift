//
//  SchedulerWidgetBundle.swift
//  SchedulerWidget
//
//  Created by James Chang on 8/1/24.
//

import WidgetKit
import SwiftUI

let sharedUserDefaults: UserDefaults? = {
    #if os(iOS)
    return UserDefaults(suiteName: "group.com.Scheduler.ShareDefaults")
    #elseif os(macOS)
    return UserDefaults(suiteName: "W98QTWY44A.com.Scheduler.ShareDefaults")
    #else
    return nil
    #endif
}()

@main
struct SchedulerWidgetBundle: WidgetBundle {
    var body: some Widget {
        SchedulerWidget()
    }
}
