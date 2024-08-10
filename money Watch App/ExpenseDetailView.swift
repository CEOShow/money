//
//  ExpenseDetailView.swift
//  money Watch App
//
//  Created by Show on 2024/7/28.
//

import SwiftUI

struct ExpenseDetailView: View {
    let accountBook: AccountBook
    @State private var expenses: [Expense] = []
    @State private var editingExpense: Expense?
    @State private var showingEditView = false
    @State private var refreshID = UUID()
    
    var body: some View {
        List {
            ForEach(expenses) { expense in
                ExpenseRow(expense: expense)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive, action: {
                            deleteExpense(expense)
                        }) {
                            Label("刪除", systemImage: "trash")
                        }
                        
                        Button(role: .none , action: {
                            editingExpense = expense
                            showingEditView = true
                        }) {
                            Label("編輯", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
            }
            .listRowInsets(EdgeInsets())
            .id(refreshID)
        }
        .navigationTitle("詳細明細")
        .onAppear {
            loadExpenses()
        }
        .fullScreenCover(item: $editingExpense) { expense in
            ExpenseInputView(accountBook: accountBook, editingExpense: expense, onSave: { updatedExpense in
                if let index = expenses.firstIndex(where: { $0.id == updatedExpense.id }) {
                    expenses[index] = updatedExpense
                }
                editingExpense = nil
                loadExpenses()
                refreshID = UUID()
            })
        }
    }
    
    private func loadExpenses() {
        expenses = AccountingManager.shared.getExpenses(for: accountBook.id)
    }
    
    private func deleteExpense(_ expense: Expense) {
        if AccountingManager.shared.deleteExpense(id: expense.id) {
            expenses.removeAll { $0.id == expense.id }
            refreshID = UUID()
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.note)
                    .font(.headline) // 這裡可以根據需要調整大小
                Text(getCategoryName(for: expense.categoryId))
                    .font(.title3) // 改成較大的字體
                    .foregroundColor(.blue)
                Text(formatDate(expense.date))
                    .font(.body) // 調整日期文字的大小
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(formatBalance(expense.income))
                .font(.headline)
                .foregroundColor(expense.income >= 0 ? .green : .red)
        }
        .padding()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func getCategoryName(for categoryId: Int) -> String {
        Category(rawValue: categoryId)?.name ?? "未知類別"
    }
    
    private func formatBalance(_ balance: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        let number = NSNumber(value: abs(balance))
        let formattedString = formatter.string(from: number) ?? "0"
        
        let finalString = balance.truncatingRemainder(dividingBy: 1) == 0 ?
            String(format: "%.0f", abs(balance)) : formattedString
        
        return balance < 0 ? "-$\(finalString)" : "$\(finalString)"
    }
}

struct ExpenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseDetailView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
    }
}
