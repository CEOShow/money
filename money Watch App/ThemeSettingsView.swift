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
                mainContent
            }
            .navigationTitle("Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var mainContent: some View {
        VStack(spacing: 20) {
            headerSection
            backgroundTypeSection
            themeOptionsSection
            previewSection
            Spacer(minLength: 20)
        }
        .padding()
    }
    
    private var headerSection: some View {
        Text("Theme Settings")
            .font(.headline)
            .padding(.top)
    }
    
    private var backgroundTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Background Type")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            backgroundTypeGrid
        }
    }
    
    private var backgroundTypeGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
            ForEach(BackgroundType.allCases, id: \.self) { type in
                backgroundTypeButton(for: type)
            }
        }
    }
    
    private func backgroundTypeButton(for type: BackgroundType) -> some View {
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
    
    @ViewBuilder
    private var themeOptionsSection: some View {
        switch themeManager.backgroundType {
        case .gradient:
            GradientThemeSection(themeManager: themeManager)
        case .solidColor:
            SolidColorThemeSection(themeManager: themeManager)
        }
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preview")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            previewCard
        }
    }
    
    private var previewCard: some View {
        ZStack {
            themeManager.currentBackground()
            
            VStack {
                Text("My Account")
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
}

@available(watchOS 10.0, *)
struct GradientThemeSection: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gradient Theme")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            gradientGrid
        }
    }
    
    private var gradientGrid: some View {
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

@available(watchOS 10.0, *)
struct SolidColorThemeSection: View {
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Solid Color Theme")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            solidColorGrid
        }
    }
    
    private var solidColorGrid: some View {
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

@available(watchOS 10.0, *)
struct ThemePreviewCard: View {
    let title: String
    let isSelected: Bool
    let background: AnyView
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            cardContent
        }
        .frame(height: 60)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .buttonStyle(PlainButtonStyle())
    }
    
    private var cardContent: some View {
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
                selectionIndicator
            }
        }
    }
    
    private var selectionIndicator: some View {
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

#Preview {
    ThemeSettingsView()
}
