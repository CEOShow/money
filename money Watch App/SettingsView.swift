//
//  SettingsView.swift
//  9歲記帳
//
//  Created by Show on 2025/1/25.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("Settings")
            Button("Close") {
                isPresented = false
            }
        }
    }
}
