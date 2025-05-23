//
//  QuickExpenseView.swift
//  money Watch App
//
//  Created by Show on 2024/12/19.
//

import SwiftUI
import UIKit

@available(watchOS 10.0, *)
struct QuickExpenseView: View {
    let accountBook: AccountBook
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedAmount: Double = 0
    @State private var customAmount: String = ""
    @State private var selectedCategory: Category = .foodAndEntertainment
    @State private var note: String = ""
    @State private var showingCustomAmount = false
    @State private var showingNote = false
    
    // 常用金額
    private let quickAmounts: [Double] = [50, 100, 150, 200, 300, 500]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("快速記帳")
                    .font(.headline)
                    .padding(.top)
                
                // 金額選擇
                VStack(alignment: .leading, spacing: 8) {
                    Text("金額")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(quickAmounts, id: \.self) { amount in
                            Button(action: {
                                selectedAmount = amount
                            }) {
                                Text("$\(Int(amount))")
                                    .font(.caption)
                                    .foregroundColor(selectedAmount == amount ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(selectedAmount == amount ? Color.blue : Color.gray.opacity(0.2))
                                    .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        // 自訂金額按鈕
                        Button(action: {
                            showingCustomAmount = true
                        }) {
                            if selectedAmount > 0 && !quickAmounts.contains(selectedAmount) {
                                Text("$\(Int(selectedAmount))")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .cornerRadius(6)
                            } else {
                                Text("其他")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(6)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // 分類選擇
                VStack(alignment: .leading, spacing: 8) {
                    Text("分類")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Picker("分類", selection: $selectedCategory) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.name)
                                .tag(category)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 80)
                }
                
                // 備註
                VStack(alignment: .leading, spacing: 8) {
                    Text("備註")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Button(action: {
                        showingNote = true
                    }) {
                        HStack {
                            Text(note.isEmpty ? "點擊新增備註" : note)
                                .font(.caption)
                                .foregroundColor(note.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "pencil")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(6)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // 確認按鈕
                Button("確認記帳") {
                    saveExpense()
                }
                .disabled(selectedAmount <= 0)
                .padding()
                .frame(maxWidth: .infinity)
                .background(selectedAmount > 0 ? Color.green : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(8)
                .font(.caption)
                
                // 取消按鈕
                Button("取消") {
                    dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.3))
                .foregroundColor(.primary)
                .cornerRadius(8)
                .font(.caption)
            }
            .padding()
        }
        .sheet(isPresented: $showingCustomAmount) {
            CustomAmountView(amount: $selectedAmount)
        }
        .sheet(isPresented: $showingNote) {
            NoteInputView(note: $note)
        }
    }
    
    private func saveExpense() {
        let expenseAmount = -abs(selectedAmount) // 負數表示支出
        let finalNote = note.isEmpty ? selectedCategory.name : note
        
        let success = AccountingManager.shared.addExpense(
            bookId: accountBook.id,
            income: expenseAmount,
            date: Date(),
            note: finalNote,
            category: selectedCategory
        )
        
        if success {
            onSave()
            dismiss()
        }
    }
}

@available(watchOS 10.0, *)
struct CustomAmountView: View {
    @Binding var amount: Double
    @Environment(\.dismiss) private var dismiss
    @State private var amountText: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("自訂金額")
                .font(.headline)
            
            TextField("輸入金額", text: $amountText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)
            
            HStack(spacing: 12) {
                Button("取消") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.3))
                .foregroundColor(.primary)
                .cornerRadius(6)
                
                Button("確認") {
                    if let value = Double(amountText), value > 0 {
                        amount = value
                    }
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding()
        .onAppear {
            if amount > 0 {
                amountText = String(format: "%.0f", amount)
            }
        }
    }
}

@available(watchOS 10.0, *)
struct NoteInputView: View {
    @Binding var note: String
    @Environment(\.dismiss) private var dismiss
    @State private var noteText: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("備註")
                .font(.headline)
            
            TextField("輸入備註", text: $noteText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)
            
            HStack(spacing: 12) {
                Button("取消") {
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.3))
                .foregroundColor(.primary)
                .cornerRadius(6)
                
                Button("確認") {
                    note = noteText
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
        }
        .padding()
        .onAppear {
            noteText = note
        }
    }
}

#Preview {
    if #available(watchOS 10.0, *) {
        QuickExpenseView(
            accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"),
            onSave: {}
        )
    } else {
        // Fallback on earlier versions
    }
} 
