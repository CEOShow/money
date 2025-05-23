//
//  VoiceExpenseView.swift
//  money Watch App
//
//  Created by Show on 2024/12/19.
//

import SwiftUI
import UIKit

@available(watchOS 10.0, *)
struct VoiceExpenseView: View {
    let accountBook: AccountBook
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var recordedText = ""
    @State private var amount: Double = 0
    @State private var note = ""
    @State private var showingConfirmation = false
    @State private var showingTextInput = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("語音記帳")
                .font(.headline)
                .padding(.top)
            
            // 語音輸入區域
            VStack(spacing: 12) {
                if recordedText.isEmpty {
                    Text("點擊按鈕開始聽寫")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                } else {
                    Text("聽寫內容:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(recordedText)
                        .font(.caption)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                        .multilineTextAlignment(.center)
                }
                
                // 聽寫按鈕
                Button(action: {
                    showingTextInput = true
                }) {
                    Image(systemName: "mic")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 解析結果顯示
            if amount > 0 || !note.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("解析結果:")
                        .font(.caption2)
                        .fontWeight(.semibold)
                    
                    if amount > 0 {
                        HStack {
                            Text("金額:")
                                .foregroundColor(.secondary)
                            Text("$\(Int(amount))")
                                .fontWeight(.semibold)
                        }
                        .font(.caption2)
                    }
                    
                    if !note.isEmpty {
                        HStack {
                            Text("備註:")
                                .foregroundColor(.secondary)
                            Text(note)
                                .fontWeight(.semibold)
                        }
                        .font(.caption2)
                    }
                }
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)
            }
            
            Spacer()
            
            // 確認按鈕
            if amount > 0 && !note.isEmpty {
                Button("確認記帳") {
                    showingConfirmation = true
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(6)
                .font(.caption)
            }
            
            // 取消按鈕
            Button("取消") {
                dismiss()
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.3))
            .foregroundColor(.primary)
            .cornerRadius(6)
            .font(.caption)
        }
        .padding()
        .sheet(isPresented: $showingTextInput) {
            TextInputView(text: $recordedText) {
                processVoiceInput(recordedText)
            }
        }
        .alert("確認記帳", isPresented: $showingConfirmation) {
            Button("確認") {
                saveExpense()
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("記錄支出 $\(Int(amount)) - \(note)")
        }
    }
    
    private func processVoiceInput(_ text: String) {
        let result = SiriShortcutsManager.shared.processVoiceInput(text)
        
        if let extractedAmount = result.amount {
            amount = extractedAmount
        }
        
        if let extractedNote = result.note {
            note = extractedNote
        }
    }
    
    private func saveExpense() {
        SiriShortcutsManager.shared.quickAddExpense(amount: amount, note: note) { success in
            DispatchQueue.main.async {
                if success {
                    onSave()
                    dismiss()
                } else {
                    // 顯示錯誤信息
                    print("Failed to save expense")
                }
            }
        }
    }
}

// 文字輸入視圖（使用系統聽寫功能）
@available(watchOS 10.0, *)
struct TextInputView: View {
    @Binding var text: String
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("語音輸入")
                .font(.headline)
            
            Text("請說出記帳內容")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("例如：「記帳 100 元午餐」")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("開始聽寫") {
                // 在實際的 watchOS 環境中，這會觸發系統聽寫
                presentDictation()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("取消") {
                dismiss()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.3))
            .foregroundColor(.primary)
            .cornerRadius(8)
        }
        .padding()
    }
    
    private func presentDictation() {
        // 模擬聽寫結果，在實際應用中會使用系統聽寫
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // 這裡會是真實的聽寫結果
            text = "記帳 150 元咖啡" // 示例文本
            onComplete()
            dismiss()
        }
    }
}

#Preview {
    VoiceExpenseView(
        accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"),
        onSave: {}
    )
} 