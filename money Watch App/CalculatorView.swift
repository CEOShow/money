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
    @State private var previousInput: String = ""
    @State private var currentOperation: String? = nil
    @State private var lastNumber: String = ""
    @State private var shouldResetInput = false
    @State private var pressedButton: String? = nil
    @State private var fontSize: CGFloat = 32
    
    let buttons: [[String]] = [
        ["C", "確認"],
        ["7", "8", "9", "÷"],
        ["4", "5", "6", "×"],
        ["1", "2", "3", "-"],
        ["0", ".", "=", "+"],
    ]
    
    let maxInputLength = 12 // 最大輸入長度
    let minFontSize: CGFloat = 16 // 最小字體大小
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    Text(formattedInput)
                        .font(.system(size: fontSize, weight: .bold))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .trailing) // 將文本對齊到右邊
                        .padding(.trailing, 8)
                        .onChange(of: formattedInput) { newValue in
                            adjustFontSize(for: newValue, in: geometry.size.width - 80)
                        }
                    
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
                
                VStack(spacing: 4) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 4) {
                            ForEach(row, id: \.self) { button in
                                CalculatorButton(
                                    title: button,
                                    size: buttonSize(for: geometry.size, button: button),
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

    private func adjustFontSize(for text: String, in width: CGFloat) {
        let testString = text as NSString
        var newSize = fontSize
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: newSize, weight: .bold)]
        
        // 根據寬度調整字體大小
        while testString.size(withAttributes: attributes).width > width && newSize > minFontSize {
            newSize -= 1
        }
        
        fontSize = newSize
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
            if shouldResetInput {
                currentInput = button
                shouldResetInput = false
            } else {
                if currentInput.count < maxInputLength || currentInput == "0" {
                    currentInput = currentInput == "0" ? button : currentInput + button
                }
            }
        }
    }
    
    private func deleteLastDigit() {
        if currentInput.count > 1 {
            currentInput.removeLast()
            fontSize = 32
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
        fontSize = 32
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
        case "+": result = numA + numB
        case "-": result = numA - numB
        case "×": result = numA * numB
        case "÷":
            if numB == 0 {
                return currentInput
            }
            result = numA / numB
        default: return currentInput
        }
        
        return formatResult(result)
    }

    private func formatResult(_ result: Double) -> String {
        if result.isInfinite || result.isNaN {
            return currentInput
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        
        if abs(result) > 999999999 {
            formatter.maximumFractionDigits = 0
        } else if abs(result) < 0.000001 && result != 0 {
            formatter.minimumFractionDigits = 8
        } else {
            if result.truncatingRemainder(dividingBy: 1) == 0 {
                formatter.maximumFractionDigits = 0
            } else {
                formatter.maximumFractionDigits = 8
            }
        }
        
        let resultString = formatter.string(from: NSNumber(value: result)) ?? String(format: "%.2f", result)
        return resultString
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
                .scaleEffect(isPressed ? 1.5 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func buttonColor() -> Color {
        switch title {
        case "確認":
            return .green
        case "+", "-", "×", "÷", "=":
            return .orange
        case "C":
            return .red
        default:
            return .blue
        }
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView(amount: .constant(""), isIncome: .constant(true))
            .previewDevice("Apple Watch Series 7")
    }
}
