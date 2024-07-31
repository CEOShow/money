//
//  calculatorView.swift
//  money Watch App
//
//  Created by Show on 2024/5/21.
//

import SwiftUI

struct CalculatorView: View {
    @Binding var amount: String
    @Binding var isIncome: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var currentInput: String = "0"
    @State private var pressedButton: String? = nil
    
    let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["0", ".", "確認"]
    ]
    
    let maxInputLength = 9 // 設置最大輸入長度
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                // 顯示金額
                HStack {
                    Spacer()
                    AdaptiveText(text: formattedInput, maxSize: 32)
                        .frame(height: 40)
                        .padding(.trailing, 8)
                    
                    Button(action: { deleteLastDigit() }) {
                        Image(systemName: "delete.left.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(8)
                    }.buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 8)
                
                // 數字鍵盤
                VStack(spacing: 4) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(row, id: \.self) { button in
                                CalculatorButton(
                                    title: button,
                                    size: buttonSize(for: geometry.size),
                                    isPressed: pressedButton == button,
                                    action: { buttonTapped(button) }
                                )
                            }
                        }
                    }
                }
                .padding(4)
            }
            .background(Color.primary.colorInvert())
        }
    }
    
    private var formattedInput: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
        if let number = Double(currentInput) {
            return formatter.string(from: NSNumber(value: number)) ?? currentInput
        }
        return currentInput
    }
    
    private func buttonSize(for size: CGSize) -> CGSize {
        let width = (size.width - 16 - 12) / 3
        return CGSize(width: width, height: width * 0.4)
    }
    
    private func buttonTapped(_ button: String) {
        pressedButton = button
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            pressedButton = nil
        }
        
        switch button {
        case "確認":
            amount = currentInput
            dismiss()
        case ".":
            if !currentInput.contains(".") && currentInput.count < maxInputLength {
                currentInput += "."
            }
        default:
            if currentInput == "0" {
                currentInput = button
            } else if currentInput.count < maxInputLength {
                currentInput += button
            }
        }
    }
    
    private func deleteLastDigit() {
        if !currentInput.isEmpty {
            currentInput.removeLast()
            if currentInput.isEmpty {
                currentInput = "0"
            }
        }
    }
}

struct AdaptiveText: View {
    let text: String
    let maxSize: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Text(text)
                .font(.system(size: maxSize, weight: .bold))
                .minimumScaleFactor(0.1)
                .scaledToFit()
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .trailing)
        }
    }
}

struct CalculatorButton: View {
    let title: String
    let size: CGSize
    let isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .frame(width: size.width, height: size.height)
                .background(buttonColor())
                .foregroundColor(.white)
                .cornerRadius(8)
                .scaleEffect(isPressed ? 1.5 : 1.0) // 將放大效果從 1.1 增加到 1.2
                .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func buttonColor() -> Color {
        switch title {
        case "確認":
            return .green
        default:
            return .blue
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView(amount: .constant("0"), isIncome: .constant(false))
    }
}
