//
//  SettingsView.swift
//  money Watch App
//
//  Created by Show on 2024/12/19.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isPresented: Bool
    @State private var showingThemeSettings = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    // 主題設定
                    Button(action: {
                        showingThemeSettings = true
                    }) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("Theme Settings")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                } header: {
                    Text("General")
                }
                
                Section {
                    // 關於App
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        Text("About")
                        Spacer()
                        Text("v2.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Support")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .sheet(isPresented: $showingThemeSettings) {
            ThemeSettingsView()
        }
    }
}
