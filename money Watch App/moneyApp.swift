//
//  moneyApp.swift
//  money Watch App
//
//  Created by Show on 2024/5/3.
//

import SwiftUI

@main
struct money_Watch_AppApp: App {
    init() {
        // 初始化 AccountingManager
        _ = AccountingManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
