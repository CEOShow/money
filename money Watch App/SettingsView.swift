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
                            Text("主題設定")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    // 語言設定
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.green)
                            .frame(width: 20)
                        Text("語言")
                        Spacer()
                        Text("繁體中文")
                            .foregroundColor(.secondary)
                    }
                    
                    // 幣別設定
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        Text("預設幣別")
                        Spacer()
                        Text("TWD")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("一般設定")
                }
                
                Section {
                    // 關於App
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                            .frame(width: 20)
                        Text("關於")
                        Spacer()
                        Text("v2.0")
                            .foregroundColor(.secondary)
                    }
                    

                    
                    // 意見回饋
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.pink)
                            .frame(width: 20)
                        Text("意見回饋")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                } header: {
                    Text("支援")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") {
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
