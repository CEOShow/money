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
    
    let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["0", ".", "確認"]
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) { // 調整垂直間距
                // 顯示金額
                HStack {
                    Text(currentInput)
                        .font(.system(size: 24, weight: .bold)) // 調整字體大小
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal, 8)
                    
                    Button(action: { deleteLastDigit() }) {
                        Image(systemName: "delete.left.fill")
                            .resizable()
                            .frame(width: 24, height: 24) // 調整刪除按鈕大小
                            .padding(8)
                    }.buttonStyle(PlainButtonStyle())
                }
                
                // 數字鍵盤
                VStack(spacing: 4) { // 調整行之間的間距
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 4) { // 調整按鈕間距
                            ForEach(row, id: \.self) { button in
                                CalculatorButton(
                                    title: button,
                                    size: buttonSize(for: geometry.size),
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
    
    private func buttonSize(for size: CGSize) -> CGSize {
        let width = (size.width - 16 - 12) / 3 // 調整按鈕間距，留出額外空間
        return CGSize(width: width, height: width * 0.4) // 調整按鈕高度比例，使其扁平
    }
    
    private func buttonTapped(_ button: String) {
        switch button {
        case "確認":
            amount = currentInput
            dismiss()
        case ".":
            if !currentInput.contains(".") {
                currentInput += "."
            }
        default:
            if currentInput == "0" {
                currentInput = button
            } else {
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

struct CalculatorButton: View {
    let title: String
    let size: CGSize
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium)) // 調整字體大小
                .frame(width: size.width, height: size.height)
                .background(buttonColor())
                .foregroundColor(.white)
                .cornerRadius(8) // 調整圓角半徑
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

#Preview {
    CalculatorView(amount: .constant("0"), isIncome: .constant(false))
}
