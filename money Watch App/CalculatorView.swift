//
//  calculatorView.swift
//  money Watch App
//
//  Created by Show on 2024/5/21.
//

import SwiftUI
import WatchKit

struct CalculatorView: View {
    @Binding var amount: String
    @Binding var isIncome: Bool
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentInput: String = "0"
    @State private var previousInput: String = ""
    @State private var currentOperation: String? = nil
    @State private var lastNumber: String = ""
    @State private var shouldResetInput = false
    @State private var pressedButton: String? = nil
    
    let buttons: [[String]] = [
        ["C", "確認"],
        ["7", "8", "9", "÷"],
        ["4", "5", "6", "×"],
        ["1", "2", "3", "-"],
        ["0", ".", "=", "+"],
    ]
    
    let maxInputLength = 8 // 最大數字長度 8
    let maxValue: Double = 99999999 // 最大數值 99999999
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                // 顯示輸入內容
                HStack {
                    Spacer()
                    Text(formattedInput)
                        .font(.system(size: 23, weight: .bold)) // 字體大小設為 24
                        .lineLimit(1) // 防止換行
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 8)
                        .minimumScaleFactor(0.5) // 設定最小縮小比例為 50%
                    
                    // 刪除按鈕
                    Button(action: { deleteLastDigit() }) {
                        Image(systemName: "delete.left.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(8)
                    }
                    .buttonStyle(PlainButtonStyle()) // 設定按鈕樣式
                }
                .padding(.horizontal, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.horizontal, 8)
                
                // 數字按鈕
                VStack(spacing: 4) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(row, id: \.self) { button in
                                CalculatorButton(
                                    title: button,
                                    size: buttonSize(for: geometry.size, button: button),
                                    isPressed: pressedButton == button,
                                    isEnabled: button != "確認" || isValidNumber, // 確保按下"確認"是有效的
                                    action: {
                                        WKInterfaceDevice.current().play(.click)
                                        buttonTapped(button)
                                    }
                                )
                                .buttonStyle(PlainButtonStyle()) // 設定按鈕樣式
                            }
                        }
                    }
                }
                .padding(4)
            }
            .background(Color.primary.colorInvert())
        }
    }
    
    private var isValidNumber: Bool {
        guard let number = Double(currentInput) else { return false }
        return number <= maxValue && currentInput != "錯誤" && currentInput != "0"
    }
    
    private var formattedInput: String {
        if currentInput == "錯誤" {
            return currentInput
        }
        
        guard let number = Double(currentInput) else { return currentInput }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 2
        }
        
        return formatter.string(from: NSNumber(value: number)) ?? currentInput
    }
    
    private func buttonSize(for size: CGSize, button: String) -> CGSize {
        let width = (size.width - 20 - 16) / 4
        let height = width * 0.4
        if button == "確認" {
            return CGSize(width: width * 2 + 4, height: height)
        }
        return CGSize(width: width, height: height)
    }
    
    private func buttonTapped(_ button: String) {
        pressedButton = button
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            pressedButton = nil
        }
        
        switch button {
        case "確認":
            if isValidNumber {
                amount = currentInput
                dismiss()
            }
        case "C":
            clear()
        case "+", "-", "×", "÷":
            setOperation(button)
        case "=":
            calculateResult()
        case ".":
            if !currentInput.contains(".") {
                currentInput += "."
            }
        default:
            // 限制數字長度和數值
            if currentInput.count < maxInputLength {
                if shouldResetInput {
                    currentInput = button
                    shouldResetInput = false
                } else {
                    let newInput = currentInput == "0" ? button : currentInput + button
                    if let number = Double(newInput), number <= maxValue {
                        currentInput = newInput
                    }
                }
            }
        }
    }
    
    private func deleteLastDigit() {
        if currentInput == "錯誤" {
            currentInput = "0"
        } else if currentInput.count > 1 {
            currentInput.removeLast()
        } else {
            currentInput = "0"
        }
    }
    
    private func clear() {
        currentInput = "0"
        previousInput = ""
        currentOperation = nil
        lastNumber = ""
        shouldResetInput = false
    }
    
    private func setOperation(_ operation: String) {
        if currentOperation != nil {
            calculateResult()
        }
        previousInput = currentInput
        currentOperation = operation
        shouldResetInput = true
    }
    
    private func calculateResult() {
        if currentOperation == nil {
            if !lastNumber.isEmpty && !previousInput.isEmpty {
                currentInput = calculate(previousInput, lastNumber, currentOperation ?? "+")
            }
        } else {
            if previousInput.isEmpty {
                previousInput = currentInput
            }
            lastNumber = currentInput
            currentInput = calculate(previousInput, currentInput, currentOperation ?? "+")
        }
        
        previousInput = currentInput
        shouldResetInput = true
    }
    
    private func calculate(_ a: String, _ b: String, _ operation: String) -> String {
        guard let numA = Double(a), let numB = Double(b) else { return currentInput }
        
        let result: Double
        switch operation {
        case "+":
            result = numA + numB
            if result > maxValue {
                return previousInput
            }
        case "-":
            result = numA - numB
        case "×":
            let product = numA * numB
            if product > maxValue {
                return previousInput
            }
            result = product
        case "÷":
            if numB == 0 {
                return "錯誤"
            }
            result = numA / numB
        default: return currentInput
        }
        
        if result.isInfinite || result.isNaN {
            return "錯誤"
        }
        
        return formatResult(result)
    }
    
    private func formatResult(_ result: Double) -> String {
        if result.isInfinite || result.isNaN {
            return "錯誤"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        if result.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 2
        }
        
        return formatter.string(from: NSNumber(value: result)) ?? "錯誤"
    }
}

struct CalculatorButton: View {
    let title: String
    let size: CGSize
    let isPressed: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .frame(width: size.width, height: size.height)
                .background(buttonColor().opacity(isEnabled ? 1.0 : 0.3))
                .foregroundColor(.white)
                .cornerRadius(8)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle()) // 設定按鈕樣式
    }
    
    private func buttonColor() -> Color {
        switch title {
        case "C":
            return .red
        case "確認":
            return .green
        case "÷", "×", "-", "+":
            return .orange
        default:
            return .blue
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView(amount: .constant("0"), isIncome: .constant(true))
            .previewDevice("Apple Watch SE (40mm)")
    }
}
