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
    @State private var singletransaction: Double = 0
    
    var body: some View {
        List {
            ForEach(expenses) { expense in
                ExpenseRow(expense: expense, expenses: $expenses)
            }
        }
        .navigationTitle("詳細明細")
        .onAppear {
            loadExpenses()
        }

        
    }
    
    private func loadExpenses() {
        expenses = AccountingManager.shared.getExpenses(for: accountBook.id)
    }
    
}

struct ExpenseRow: View {
    let expense: Expense
    @Binding var expenses: [Expense]
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.note)
                    .font(.headline)
                Text(formatDate(expense.date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(formatBalance(expense.income))
                .font(.headline)
                .foregroundColor(expense.income >= 0 ? .green : .red)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                deleteExpense()
            } label: {
                Label("刪除", systemImage: "trash")
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "TWD"
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    private func deleteExpense() {
        if AccountingManager.shared.deleteExpense(id: expense.id) {
            if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
                expenses.remove(at: index)
            }
        }
    }
    private func formatBalance(_ balance: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        
        let number = NSNumber(value: abs(balance))
        let formattedString = formatter.string(from: number) ?? "$0"
        
        return balance < 0 ? "-\(formattedString)" : formattedString
    }

}

#Preview {
    ExpenseDetailView(accountBook: AccountBook(id: 1, currency: "TWD", name: "測試帳本"))
}
