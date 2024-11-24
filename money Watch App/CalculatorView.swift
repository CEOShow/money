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
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                // 顯示輸入內容
                HStack {
                    Spacer()
                    Text(currentInput)
                        .font(.system(size: 23, weight: .bold))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 8)
                        .minimumScaleFactor(0.5)
                    
                    // 刪除按鈕
                    Button(action: { deleteLastDigit() }) {
                        Image(systemName: "delete.left.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(8)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                                    isEnabled: button != "確認" || currentInput != "錯誤", // 只有顯示「錯誤」時才禁用「確認」按鈕
                                    action: {
                                        WKInterfaceDevice.current().play(.click)
                                        buttonTapped(button)
                                    }
                                )
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(4)
            }
            .background(Color.primary.colorInvert())
        }
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
            amount = currentInput
            dismiss()
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
            if currentInput.count < maxInputLength {
                if shouldResetInput {
                    currentInput = button
                    shouldResetInput = false
                } else {
                    currentInput = currentInput == "0" ? button : currentInput + button
                }
            }
        }
    }
    
    private func deleteLastDigit() {
        if currentInput.count > 1 {
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
        
        // 在按下運算符時，將 currentInput 重設為 "0"
        currentInput = "0"
    }
    
    private func calculateResult() {
        if let operation = currentOperation, let numA = Double(previousInput), let numB = Double(currentInput) {
            let result: Double
            switch operation {
            case "+":
                result = numA + numB
            case "-":
                result = numA - numB
            case "×":
                result = numA * numB
            case "÷":
                // 當除數是 0 且被除數也是 0 時，顯示錯誤
                if numB == 0 {
                    currentInput = "錯誤"
                    return
                }
                result = numA / numB
            default:
                return
            }
            
            // 結果顯示時避免出現科學記號 (e) 或過長數字，顯示最多 8 位數
            currentInput = formatNumber(result)
        }
        currentOperation = nil
        shouldResetInput = true
    }
    
    private func formatNumber(_ number: Double) -> String {
        if number.isInfinite || number.isNaN {
            return "錯誤"
        }
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        if let formattedString = formatter.string(from: NSNumber(value: number)) {
            return formattedString
        }
        return "錯誤"
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
        .buttonStyle(PlainButtonStyle())
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
