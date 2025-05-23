//
//  ThemeManager.swift
//  money Watch App
//
//  Created by Show on 2024/12/19.
//

import SwiftUI
import Foundation

// 背景主題類型
enum BackgroundType: String, CaseIterable {
    case gradient = "gradient"
    case solidColor = "solidColor"
    case image = "image"
    
    var displayName: String {
        switch self {
        case .gradient: return "漸層"
        case .solidColor: return "純色"
        case .image: return "圖片"
        }
    }
}

// 預設漸層主題
enum GradientTheme: String, CaseIterable {
    case bluePurple = "bluePurple"
    case pinkOrange = "pinkOrange"
    case greenBlue = "greenBlue"
    case purpleRed = "purpleRed"
    case orangeYellow = "orangeYellow"
    case darkBlue = "darkBlue"
    
    var displayName: String {
        switch self {
        case .bluePurple: return "藍紫漸層"
        case .pinkOrange: return "粉橙漸層"
        case .greenBlue: return "綠藍漸層"
        case .purpleRed: return "紫紅漸層"
        case .orangeYellow: return "橙黃漸層"
        case .darkBlue: return "深藍漸層"
        }
    }
    
    var gradient: LinearGradient {
        switch self {
        case .bluePurple:
            return LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pinkOrange:
            return LinearGradient(
                gradient: Gradient(colors: [.pink, .orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .greenBlue:
            return LinearGradient(
                gradient: Gradient(colors: [.green, .blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .purpleRed:
            return LinearGradient(
                gradient: Gradient(colors: [.purple, .red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .orangeYellow:
            return LinearGradient(
                gradient: Gradient(colors: [.orange, .yellow]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .darkBlue:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// 純色主題
enum SolidColorTheme: String, CaseIterable {
    case blue = "blue"
    case green = "green"
    case purple = "purple"
    case red = "red"
    case orange = "orange"
    case pink = "pink"
    case gray = "gray"
    case black = "black"
    
    var displayName: String {
        switch self {
        case .blue: return "藍色"
        case .green: return "綠色"
        case .purple: return "紫色"
        case .red: return "紅色"
        case .orange: return "橙色"
        case .pink: return "粉色"
        case .gray: return "灰色"
        case .black: return "黑色"
        }
    }
    
    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .purple: return .purple
        case .red: return .red
        case .orange: return .orange
        case .pink: return .pink
        case .gray: return .gray
        case .black: return .black
        }
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var backgroundType: BackgroundType {
        didSet {
            UserDefaults.standard.set(backgroundType.rawValue, forKey: "backgroundType")
        }
    }
    
    @Published var gradientTheme: GradientTheme {
        didSet {
            UserDefaults.standard.set(gradientTheme.rawValue, forKey: "gradientTheme")
        }
    }
    
    @Published var solidColorTheme: SolidColorTheme {
        didSet {
            UserDefaults.standard.set(solidColorTheme.rawValue, forKey: "solidColorTheme")
        }
    }
    
    private init() {
        // 載入儲存的設定
        if let backgroundTypeString = UserDefaults.standard.string(forKey: "backgroundType"),
           let savedBackgroundType = BackgroundType(rawValue: backgroundTypeString) {
            self.backgroundType = savedBackgroundType
        } else {
            self.backgroundType = .gradient
        }
        
        if let gradientThemeString = UserDefaults.standard.string(forKey: "gradientTheme"),
           let savedGradientTheme = GradientTheme(rawValue: gradientThemeString) {
            self.gradientTheme = savedGradientTheme
        } else {
            self.gradientTheme = .bluePurple
        }
        
        if let solidColorThemeString = UserDefaults.standard.string(forKey: "solidColorTheme"),
           let savedSolidColorTheme = SolidColorTheme(rawValue: solidColorThemeString) {
            self.solidColorTheme = savedSolidColorTheme
        } else {
            self.solidColorTheme = .blue
        }
    }
    
    // 獲取當前背景視圖
    @ViewBuilder
    func currentBackground() -> some View {
        switch backgroundType {
        case .gradient:
            gradientTheme.gradient
                .ignoresSafeArea()
        case .solidColor:
            solidColorTheme.color
                .ignoresSafeArea()
        case .image:
            // 暫時使用漸層，之後可以擴展為圖片
            gradientTheme.gradient
                .ignoresSafeArea()
        }
    }
} 