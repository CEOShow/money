//
//  ThemeManager.swift
//  money Watch App
//
//  Created by Show on 2024/12/19.
//

import SwiftUI
import Foundation

// Background theme types
enum BackgroundType: String, CaseIterable {
    case gradient = "gradient"
    case solidColor = "solidColor"
    
    var displayName: String {
        switch self {
        case .gradient:
            return NSLocalizedString("Gradient", comment: "Gradient background type")
        case .solidColor:
            return NSLocalizedString("Solid Color", comment: "Solid color background type")
        }
    }
}

// Predefined gradient themes
enum GradientTheme: String, CaseIterable {
    case bluePurple = "bluePurple"
    case pinkOrange = "pinkOrange"
    case greenBlue = "greenBlue"
    case purpleRed = "purpleRed"
    case orangeYellow = "orangeYellow"
    case darkBlue = "darkBlue"
    
    var displayName: String {
        switch self {
        case .bluePurple:
            return NSLocalizedString("Blue Purple Gradient", comment: "Blue purple gradient background")
        case .pinkOrange:
            return NSLocalizedString("Pink Orange Gradient", comment: "Pink orange gradient background")
        case .greenBlue:
            return NSLocalizedString("Green Blue Gradient", comment: "Green blue gradient background")
        case .purpleRed:
            return NSLocalizedString("Purple Red Gradient", comment: "Purple red gradient background")
        case .orangeYellow:
            return NSLocalizedString("Orange Yellow Gradient", comment: "Orange yellow gradient background")
        case .darkBlue:
            return NSLocalizedString("Dark Blue Gradient", comment: "Dark blue gradient background")
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

// Solid color themes
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
        case .blue: return "Blue"
        case .green: return "Green"
        case .purple: return "Purple"
        case .red: return "Red"
        case .orange: return "Orange"
        case .pink: return "Pink"
        case .gray: return "Gray"
        case .black: return "Black"
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
        // Load saved settings
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
    
    // Get current background view
    @ViewBuilder
    func currentBackground() -> some View {
        switch backgroundType {
        case .gradient:
            gradientTheme.gradient
                .ignoresSafeArea()
        case .solidColor:
            solidColorTheme.color
                .ignoresSafeArea()
        }
    }
}
