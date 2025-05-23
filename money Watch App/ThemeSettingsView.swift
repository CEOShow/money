//
//  ThemeSettingsView.swift
//  money Watch App
//
//  Created by Show on 2024/12/19.
//

import SwiftUI
import UIKit

@available(watchOS 10.0, *)
struct ThemeSettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("主題設定")
                        .font(.headline)
                        .padding(.top)
                    
                    // 背景類型選擇
                    VStack(alignment: .leading, spacing: 12) {
                        Text("背景類型")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        // 使用按鈕網格代替分段控制器（適合 watchOS）
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(BackgroundType.allCases, id: \.self) { type in
                                Button(action: {
                                    themeManager.backgroundType = type
                                }) {
                                    Text(type.displayName)
                                        .font(.caption)
                                        .foregroundColor(themeManager.backgroundType == type ? .white : .primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(themeManager.backgroundType == type ? Color.blue : Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // 根據選擇的背景類型顯示不同選項
                    switch themeManager.backgroundType {
                    case .gradient:
                        GradientThemeSection(themeManager: themeManager)
                    case .solidColor:
                        SolidColorThemeSection(themeManager: themeManager)
                    case .image:
                        ImageThemeSection()
                    }
                    
                    // 預覽區域
                    VStack(alignment: .leading, spacing: 8) {
                        Text("預覽")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        ZStack {
                            themeManager.currentBackground()
                            
                            VStack {
                                Text("我的帳本")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("$12,345")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                        .frame(height: 100)
                        .cornerRadius(12)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("主題")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

@available(watchOS 10.0, *)
struct GradientThemeSection: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("漸層主題")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(GradientTheme.allCases, id: \.self) { theme in
                    ThemePreviewCard(
                        title: theme.displayName,
                        isSelected: themeManager.gradientTheme == theme,
                        background: AnyView(theme.gradient)
                    ) {
                        themeManager.gradientTheme = theme
                    }
                }
            }
        }
    }
}

@available(watchOS 10.0, *)
struct SolidColorThemeSection: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("純色主題")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(SolidColorTheme.allCases, id: \.self) { theme in
                    ThemePreviewCard(
                        title: theme.displayName,
                        isSelected: themeManager.solidColorTheme == theme,
                        background: AnyView(theme.color)
                    ) {
                        themeManager.solidColorTheme = theme
                    }
                }
            }
        }
    }
}

@available(watchOS 10.0, *)
struct ImageThemeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("圖片主題")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("圖片主題功能即將推出")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
    }
}

@available(watchOS 10.0, *)
struct ThemePreviewCard: View {
    let title: String
    let isSelected: Bool
    let background: AnyView
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                background
                
                VStack {
                    Text(title)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                
                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(4)
                }
            }
        }
        .frame(height: 60)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ThemeSettingsView()
} 