//
//  ExpenseInputView.swift
//  money Watch App
//
//  Created by Show on 2024/7/19.
//

import SwiftUI

struct ExpenseInputView: View {
    @Environment(\.dismiss) var dismiss
    let accountBook: AccountBook
    var editingExpense: Expense?
    var onSave: ((Expense) -> Void)?
    
    @State private var amount: String = "0"
    @State private var selectedCategory: Category = .foodAndEntertainment
    @State private var note: String = ""
    @State private var date: Date = Date()
    @State private var isIncome: Bool = false
    @State private var showingCalculator = false
    @State private var showingCategoryPicker = false
    
    init(accountBook: AccountBook, editingExpense: Expense? = nil, onSave: ((Expense) -> Void)? = nil) {
        self.accountBook = accountBook
        self.editingExpense = editingExpense
        self.onSave = onSave
        
        if let expense = editingExpense {
            _amount = State(initialValue: String(format: "%.0f", abs(expense.income)))
            _selectedCategory = State(initialValue: Category(rawValue: expense.categoryId) ?? .foodAndEntertainment)
            _note = State(initialValue: expense.note)
            _date = State(initialValue: expense.date)
            _isIncome = State(initialValue: expense.income >= 0)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Amount Section
                Section {
                    Button(action: {
                        showingCalculator = true
                    }) {
                        Text(amount)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showingCalculator) {
                        CalculatorView(amount: $amount, isIncome: $isIncome)
                    }

                    HStack {
                        Button(action: { isIncome = false }) {
                            Text("支出")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isIncome ? Color.gray.opacity(0.3) : Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { isIncome = true }) {
                            Text("收入")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isIncome ? Color.green : Color.gray.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                
                // Category Section
                Section {
                    Button(action: {
                        showingCategoryPicker = true
                    }) {
                        HStack {
                            Text("類別")
                            Spacer()
                            Text(selectedCategory.name)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .sheet(isPresented: $showingCategoryPicker) {
                    CategoryView(selectedCategory: $selectedCategory)
                }
                
                // Note Section
                Section {
                    TextField("輸入備註", text: $note)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Date Section
                Section {
                    Text(formatDate(date))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                // Save Button
                Button(action: saveExpense) {
                    Text(editingExpense == nil ? "保存" : "更新")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle(editingExpense == nil ? "新增紀錄" : "編輯紀錄")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            print("請輸入有效的金額")
            return
        }
        
        let income = isIncome ? amountValue : -amountValue
        
        if let editingExpense = editingExpense {
            let updatedExpense = Expense(id: editingExpense.id, bookId: accountBook.id, income: income, date: date, note: note, categoryId: selectedCategory.rawValue)
            
            if AccountingManager.shared.updateExpense(updatedExpense) {
                print("紀錄已更新")
                onSave?(updatedExpense)
                dismiss()
            } else {
                print("更新失敗，請稍後再試")
            }
        } else {
            if AccountingManager.shared.addExpense(
                bookId: accountBook.id,
                income: income,
                date: date,
                note: note,
                category: selectedCategory
            ) {
                print("紀錄已保存")
                dismiss()
            } else {
                print("保存失敗，請稍後再試")
            }
        }
    }
}

struct ExpenseInputView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseInputView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
    }
}
